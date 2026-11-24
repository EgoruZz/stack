#!/bin/bash
# ═══════════════════════════════════════════════════════════════
#  Stack teardown — removes everything the stack installed/changed.
#  Run:  bash $STACK_DIR/teardown.sh [--yes] [--deep]
#    --yes   no confirmation prompts (for scripted runs)
#    --deep  also uninstall brew packages the stack added
#            (only ones absent from .brew-pre-manifest.txt — i.e. genuinely new)
#  The stack folder itself is NOT deleted (git repo — the user decides).
# ═══════════════════════════════════════════════════════════════
set -uo pipefail

STACK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ASSUME_YES=0; DEEP=0
for a in "$@"; do
    case "$a" in
        --yes) ASSUME_YES=1 ;;
        --deep) DEEP=1 ;;
        *) echo "Unknown flag: $a"; exit 1 ;;
    esac
done

confirm() {  # confirm "<question>"
    [ "$ASSUME_YES" = "1" ] && return 0
    read -r -p "$1 [y/N] " a </dev/tty || return 1
    [ "$a" = "y" ] || [ "$a" = "Y" ]
}

echo "=== Stack teardown ==="
echo "Stack dir: $STACK_DIR"

# ── 1. Detach the stack from all projects ──────────────────────
if [ -f "$STACK_DIR/projects.txt" ]; then
    while IFS= read -r p; do
        [ -z "$p" ] && continue
        case "$p" in \#*) continue ;; esac
        p="${p/#\~/$HOME}"
        if [ -d "$p" ]; then
            bash "$STACK_DIR/detach-project.sh" "$p" || echo "  ⚠️ failed: $p"
        fi
    done < <(grep -v '^\s*$' "$STACK_DIR/projects.txt" 2>/dev/null)
    echo "✅ Projects detached (AGENTS.md section + .opencode removed)"
else
    echo "ℹ️ projects.txt absent — nothing to detach"
fi

# ── 2. .zshrc — remove the managed proxy block ─────────────────
if [ -f "$HOME/.zshrc" ] && grep -q "Stack network (managed" "$HOME/.zshrc"; then
    # Delete from the "=== Stack network" comment to the closing marker
    /usr/bin/sed -i '' '/=== Stack network (managed/,/=== End Stack network ===/d' "$HOME/.zshrc"
    # Clean up a possible doubled blank line left by the removal
    /usr/bin/sed -i '' -e ':a' -e 'N' -e '$!ba' -e 's/\n\n\n\n*/\n\n/g' "$HOME/.zshrc"
    echo "✅ .zshrc: proxy block removed"
else
    echo "ℹ️ .zshrc: no managed block found"
fi

# ── 3. Personal files (secrets, Wolfram ID, sudoers template) ──
for f in "$HOME/.stack-secrets.sh" "$HOME/.stack-wolfram.conf" "$HOME/.stack-sudoers.tpl" \
         "$STACK_DIR/first-start.txt"; do
    if [ -f "$f" ]; then
        rm -f "$f"
        echo "✅ removed: $f"
    fi
done
# Permanent passwordless sudo — only with explicit confirmation
if [ -f /etc/sudoers.d/stack-agent ]; then
    if confirm "Remove passwordless sudo (/etc/sudoers.d/stack-agent, needs sudo password)?"; then
        sudo rm -f /etc/sudoers.d/stack-agent && echo "✅ sudoers entry removed"
    fi
fi

# ── 4. OpenCode client config (only if it matches the stack template) ──
OC_CONF="$HOME/.config/opencode/opencode.jsonc"
if [ -f "$OC_CONF" ] && /usr/bin/grep -q '"permission"' "$OC_CONF" 2>/dev/null \
   && ! /usr/bin/grep -qv 'permission\|edit\|webfetch\|bash\|allow\|\$schema\|config.json' "$OC_CONF"; then
    rm -f "$OC_CONF"
    echo "✅ removed: $OC_CONF (created by the stack)"
else
    echo "ℹ️ $OC_CONF kept (not stack-only)"
fi

# ── 5. Stack folder: generated artifacts (venvs, repos, builds) ─
for d in manim-env jupyter-env paraview-mcp-env julia-mcp-env \
         paraview-mcp manim-mcp julia-mcp tldraw-mcp aris-research-repo \
         WolframLanguageForJupyter skills-store craft-cli craft-downloads; do
    if [ -d "$STACK_DIR/$d" ]; then
        rm -rf "$STACK_DIR/$d"
        echo "✅ removed dir: $d"
    fi
done
for f in "$STACK_DIR/.opencode/opencode.json" "$STACK_DIR/AGENTS.md" "$STACK_DIR/.brew-pre-manifest.txt" \
         "$STACK_DIR/paraview-mcp/typing_extensions.py"; do
    [ -e "$f" ] && rm -rf "$f" && echo "✅ removed: $(basename "$f")"
done

# ── 6. npm global CLIs ─────────────────────────────────────────
for pkg in "@kitschpatrol/tldraw-cli" "firecrawl-cli"; do
    if npm ls -g "$pkg" >/dev/null 2>&1; then
        npm uninstall -g "$pkg" >/dev/null 2>&1 && echo "✅ npm uninstalled: $pkg"
    fi
done

# ── 7. VS Code extensions (only the 6 stack ones) ──────────────
if command -v code &>/dev/null; then
    for ext in tldraw-org.tldraw-vscode ms-python.python ms-toolsai.jupyter \
               julialang.language-julia wolframresearch.wolfram james-yu.latex-workshop; do
        code --uninstall-extension "$ext" >/dev/null 2>&1 && echo "✅ VS Code ext removed: $ext"
    done
fi

# ── 8. Browser caches for headless renders ─────────────────────
for d in "$HOME/.cache/puppeteer" "$HOME/.cache/ms-playwright"; do
    [ -d "$d" ] && rm -rf "$d" && echo "✅ removed: $d"
done

# ── 9. Brew packages (--deep; ONLY what is genuinely new) ──────
if [ "$DEEP" = "1" ]; then
    MANIFEST="$STACK_DIR/.brew-pre-manifest.txt"
    if [ ! -f "$MANIFEST" ]; then
        echo "⚠️ No pre-install manifest — cannot tell what the stack added."
        echo "   Skipping brew uninstall (use 'brew list' manually if needed)."
    else
        FORMULAE="python@3.12 node gh ffmpeg juliaup"
        CASKS="wolfram-engine paraview mactex tldraw visual-studio-code"
        for f in $FORMULAE; do
            if command -v brew &>/dev/null && brew list --formula "$f" &>/dev/null \
               && ! grep -qx "$f" "$MANIFEST"; then
                if confirm "brew uninstall $f (installed by the stack)?"; then
                    brew uninstall "$f" && echo "✅ brew removed: $f"
                fi
            fi
        done
        for c in $CASKS; do
            if command -v brew &>/dev/null && brew list --cask "$c" &>/dev/null \
               && ! grep -qA100 "── casks:" "$MANIFEST" | grep -qx "$c"; then
                if confirm "brew uninstall --cask $c (installed by the stack, sudo password may be asked)?"; then
                    brew uninstall --cask "$c" && echo "✅ brew cask removed: $c"
                fi
            fi
        done
    fi
else
    echo "ℹ️ brew packages kept (run with --deep to uninstall the ones the stack added)"
fi

# ── 10. Julia depot (~/.julia packages; juliaup itself via brew) ─
if [ -d "$HOME/.julia" ]; then
    if confirm "Remove the Julia package depot (~/.julia, ~1-2 GB)?"; then
        rm -rf "$HOME/.julia" && echo "✅ removed: ~/.julia"
    fi
fi

# ── 11. Wolfram AgentTools paclet ───────────────────────────────
if command -v wolframscript &>/dev/null; then
    wolframscript -code 'PacletUninstall["Wolfram/AgentTools"]' >/dev/null 2>&1 \
        && echo "✅ Wolfram AgentTools paclet uninstalled" || echo "ℹ️ AgentTools not removed (not installed)"
fi
echo "ℹ️ Wolfram license data (~/Library/Wolfram*) kept — it survives and is reusable."

echo ""
echo "=== Teardown done ==="
echo "The stack repo folder itself is left in place (it is a git repo —"
echo "delete manually if it should disappear: rm -rf $STACK_DIR)."
