#!/bin/bash
# ═══════════════════════════════════════════════════════════════
#  Stack teardown — removes everything the stack installed/changed.
#  Run:  bash scripts/teardown.sh [--yes] [--deep] [--dry]
#    --yes   no confirmation prompts (for scripted runs)
#    --deep  also uninstall brew packages the stack added
#            (only ones absent from .brew-pre-manifest.txt — i.e. genuinely new)
#    --dry   print every action without executing anything (safe audit)
#  The stack folder itself is NOT deleted (git repo — the user decides).
#  OpenCode itself is NEVER removed — the stack only uses it.
#  MCP servers and skills are project-scoped (.opencode in each project),
#  so step 1 (detach) removes them all; nothing of the stack is global.
# ═══════════════════════════════════════════════════════════════
set -uo pipefail

STACK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ASSUME_YES=0; DEEP=0; DRY=0
for a in "$@"; do
    case "$a" in
        --yes) ASSUME_YES=1 ;;
        --deep) DEEP=1 ;;
        --dry) DRY=1 ;;
        *) echo "Unknown flag: $a"; exit 1 ;;
    esac
done

confirm() {  # confirm "<question>"
    [ "$DRY" = "1" ] && return 1
    [ "$ASSUME_YES" = "1" ] && return 0
    read -r -p "$1 [y/N] " a </dev/tty || return 1
    [ "$a" = "y" ] || [ "$a" = "Y" ]
}
rmfile()    { if [ -e "$1" ]; then if [ "$DRY" = "1" ]; then echo "[dry] would remove: $1"; else rm -rf "$1"; echo "✅ removed: $1"; fi; fi; }
rmdir_()    { rmfile "$1"; }
run()       { if [ "$DRY" = "1" ]; then echo "[dry] would run: $*"; else "$@"; fi; }

echo "=== Stack teardown ===$([ "$DRY" = "1" ] && echo '  (DRY RUN — nothing is deleted)')"
echo "Stack dir: $STACK_DIR"

# ── 1. Detach the stack from all projects ──────────────────────
if [ -f "$STACK_DIR/projects.txt" ]; then
    while IFS= read -r p; do
        [ -z "$p" ] && continue
        case "$p" in \#*) continue ;; esac
        p="${p/#\~/$HOME}"
        if [ -d "$p" ]; then
            if [ "$DRY" = "1" ]; then echo "[dry] would detach: $p"
            else bash "$STACK_DIR/scripts/detach-project.sh" "$p" || echo "  ⚠️ failed: $p"; fi
        fi
    done < <(grep -v '^\s*$' "$STACK_DIR/projects.txt" 2>/dev/null)
    rmfile "$STACK_DIR/projects.txt"
    echo "✅ Projects detached (AGENTS.md section + .opencode removed)"
else
    echo "ℹ️ projects.txt absent — nothing to detach"
fi

# ── 2. .zshrc — remove the managed proxy block ─────────────────
if [ -f "$HOME/.zshrc" ] && grep -q "Stack network (managed" "$HOME/.zshrc"; then
    if [ "$DRY" = "1" ]; then
        echo "[dry] would remove the managed block from ~/.zshrc"
    else
        /usr/bin/sed -i '' '/=== Stack network (managed/,/=== End Stack network ===/d' "$HOME/.zshrc"
        /usr/bin/sed -i '' -e ':a' -e 'N' -e '$!ba' -e 's/\n\n\n\n*/\n\n/g' "$HOME/.zshrc"
        echo "✅ .zshrc: proxy block removed"
    fi
else
    echo "ℹ️ .zshrc: no managed block found"
fi

# ── 3. Personal files (secrets, Wolfram ID, sudoers template) ──
rmfile "$HOME/.stack-secrets.sh"
rmfile "$HOME/.stack-wolfram.conf"
rmfile "$HOME/.stack-sudoers.tpl"
rmfile "$STACK_DIR/first-start.txt"
# Permanent passwordless sudo — only with explicit confirmation
if [ -f /etc/sudoers.d/stack-agent ]; then
    if confirm "Remove passwordless sudo (/etc/sudoers.d/stack-agent, needs sudo password)?"; then
        run sudo rm -f /etc/sudoers.d/stack-agent && echo "✅ sudoers entry removed"
    fi
fi

# ── 4. Firecrawl state (CLI account + skills it installed globally) ──
if [ -e "$HOME/.firecrawl" ]; then
    if confirm "Remove Firecrawl state (~/.firecrawl: account, skills cache)?"; then
        rmfile "$HOME/.firecrawl"
    fi
fi
for d in "$HOME/.claude/skills" "$HOME/.config/opencode/skills" \
         "$HOME/.claude/commands" "$HOME/.codex/skills"; do
    if [ -d "$d" ] && ls "$d" 2>/dev/null | grep -q 'firecrawl'; then
        if [ "$DRY" = "1" ]; then
            echo "[dry] would remove firecrawl skills from: $d"
        elif confirm "Remove firecrawl skills from $d?"; then
            find "$d" -maxdepth 1 -iname '*firecrawl*' -exec rm -rf {} + 2>/dev/null
            echo "✅ firecrawl skills removed from: $d"
        fi
    fi
done

# ── 5. OpenCode client config (only if it is stack-only: a valid JSON
# whose top-level keys are nothing but permission/$schema) ──
OC_CONF="$HOME/.config/opencode/opencode.jsonc"
if [ -f "$OC_CONF" ] && python3 -c "
import json,sys
try:
    c=json.load(open('$OC_CONF'.replace('~','$HOME')))
    json.dump({k:v for k,v in c.items() if k=='permission' or k.startswith('\$')}, open('/dev/null','w'))
    sys.exit(0 if set(c)<= {'permission','\$schema'} else 1)
except Exception:
    sys.exit(1)
" 2>/dev/null; then
    rmfile "$OC_CONF"
else
    echo "ℹ️ $OC_CONF kept (not stack-only)"
fi

# ── 6. Stack folder: generated artifacts (venvs, repos, builds) ─
# NOTE: the brew manifest is consumed by step 10 (--deep) — save it and
# delete it only after that step (store the text, not the file).
if [ -f "$STACK_DIR/.brew-pre-manifest.txt" ]; then
    MANIFEST_CONTENT=$(cat "$STACK_DIR/.brew-pre-manifest.txt")
fi
for d in manim-env jupyter-env paraview-mcp-env julia-mcp-env \
         paraview-mcp manim-mcp julia-mcp tldraw-mcp aris-research-repo \
         WolframLanguageForJupyter skills-store craft-cli craft-downloads; do
    rmdir_ "$STACK_DIR/$d"
done
rmfile "$STACK_DIR/.opencode"
# AGENTS.md is a tracked bootstrap file — restore it, never delete it
# (also clear the skip-worktree flag the render had set, so git status is honest)
if [ "$DRY" = "1" ]; then
    echo "[dry] would restore AGENTS.md to the committed bootstrap"
else
    git -C "$STACK_DIR" update-index --no-skip-worktree AGENTS.md 2>/dev/null || true
    if git -C "$STACK_DIR" checkout -- AGENTS.md 2>/dev/null; then
        echo "✅ AGENTS.md restored to the committed bootstrap"
    else
        rmfile "$STACK_DIR/AGENTS.md"   # non-git copy — nothing to restore
    fi
fi
# ── 7. npm global CLIs ─────────────────────────────────────────
for pkg in "@kitschpatrol/tldraw-cli" "firecrawl-cli"; do
    if npm ls -g "$pkg" >/dev/null 2>&1; then
        if [ "$DRY" = "1" ]; then echo "[dry] would npm uninstall -g $pkg"
        elif confirm "npm uninstall -g $pkg (installed by the stack)?"; then
            npm uninstall -g "$pkg" >/dev/null 2>&1 && echo "✅ npm uninstalled: $pkg"; fi
    fi
done

# ── 7b. Craft Apps GUI (installed by the stack via DMG — never pre-existing) ──
for app in WordCraft GridCraft DeckCraft PdfCraft FigCraft; do
    app="/Applications/${app}.app"
    [ -d "$app" ] || continue
    if [ "$DRY" = "1" ]; then
        echo "[dry] would remove: $app"
    elif confirm "Remove $app (installed by the stack)?"; then
        rm -rf "$app" && echo "✅ removed: $app"
    fi
done

# ── 8. VS Code extensions (only the 6 stack ones) ──────────────
if command -v code &>/dev/null; then
    for ext in tldraw-org.tldraw-vscode ms-python.python ms-toolsai.jupyter \
               julialang.language-julia wolframresearch.wolfram james-yu.latex-workshop; do
        if code --list-extensions 2>/dev/null | grep -q "^$ext$"; then
            if [ "$DRY" = "1" ]; then echo "[dry] would remove VS Code ext: $ext"
            elif confirm "Uninstall VS Code extension: $ext?"; then
                code --uninstall-extension "$ext" >/dev/null 2>&1 && echo "✅ VS Code ext removed: $ext"; fi
        fi
    done
fi

# ── 9. Browser caches for headless renders ─────────────────────
if [ -e "$HOME/.cache/puppeteer" ] || [ -e "$HOME/.cache/ms-playwright" ]; then
    if confirm "Remove headless-render browser caches (~/.cache/puppeteer, ~/.cache/ms-playwright, ~400 MB)?"; then
        rmfile "$HOME/.cache/puppeteer"
        rmfile "$HOME/.cache/ms-playwright"
    fi
fi

# ── 10. Brew packages (--deep; ONLY what is genuinely new) ─────
if [ "$DEEP" = "1" ]; then
    # Manifest was captured in step 6 (before artifacts were removed)
    if [ -z "${MANIFEST_CONTENT:-}" ]; then
        echo "⚠️ No pre-install manifest — cannot tell what the stack added."
        echo "   Skipping brew uninstall (use 'brew list' manually if needed)."
    else
        FORMULAE="python@3.12 node gh ffmpeg juliaup"
        CASKS="wolfram-engine paraview mactex tldraw visual-studio-code"
        for f in $FORMULAE; do
            if command -v brew &>/dev/null && brew list --formula "$f" &>/dev/null \
               && ! grep -qx "$f" <(printf "%s\n" "$MANIFEST_CONTENT"); then
                if [ "$DRY" = "1" ]; then
                    echo "[dry] would brew uninstall: $f (installed by the stack)"
                elif confirm "brew uninstall $f (installed by the stack)?"; then
                    run brew uninstall "$f" && echo "✅ brew removed: $f"
                fi
            fi
        done
        for c in $CASKS; do
            if command -v brew &>/dev/null && brew list --cask "$c" &>/dev/null \
               && ! sed -n '/── casks:/,$p' <(printf "%s\n" "$MANIFEST_CONTENT") | grep -qx "$c"; then
                if [ "$DRY" = "1" ]; then
                    echo "[dry] would brew uninstall --cask: $c (installed by the stack, sudo password may be asked)"
                elif confirm "brew uninstall --cask $c (installed by the stack, sudo password may be asked)?"; then
                    run brew uninstall --cask "$c" && echo "✅ brew cask removed: $c"
                fi
            fi
        done
    fi
else
    echo "ℹ️ brew packages kept (run with --deep to uninstall the ones the stack added)"
fi

# ── 11. Julia depot (~/.julia packages; juliaup itself via brew) ─
if [ -d "$HOME/.julia" ]; then
    if [ "$DRY" = "1" ]; then
        echo "[dry] would remove: $HOME/.julia (Julia package depot, ~1-2 GB)"
    elif confirm "Remove the Julia package depot (~/.julia, ~1-2 GB)?"; then
        run rm -rf "$HOME/.julia" && echo "✅ removed: ~/.julia"
    fi
fi

# ── 12. Wolfram AgentTools paclet ───────────────────────────────
if command -v wolframscript &>/dev/null; then
    if [ "$DRY" = "1" ]; then
        echo "[dry] would uninstall the Wolfram AgentTools paclet"
    elif confirm "Uninstall the Wolfram AgentTools paclet?"; then
        wolframscript -code 'PacletUninstall["Wolfram/AgentTools"]' >/dev/null 2>&1 \
            && echo "✅ Wolfram AgentTools paclet uninstalled" || echo "ℹ️ AgentTools not removed (not installed)"
    fi
fi
echo "ℹ️ Wolfram license data (~/Library/Wolfram*) kept — it survives and is reusable."

echo ""
echo "=== Teardown done ===$([ "$DRY" = "1" ] && echo ' (dry run — nothing was deleted)')"
echo "The stack repo folder itself is left in place (it is a git repo —"
echo "delete manually if it should disappear: rm -rf $STACK_DIR)."
