#!/bin/bash
# Full stack update script
# Run: cd $STACK_DIR && bash update-all.sh
# Updates: brew, Apple CLT/system, external repos, tldraw-mcp,
#          Python venvs, npm CLIs, VS Code extensions, ARIS skills,
#          standalone skills, Julia, Wolfram, Craft Apps

set -uo pipefail

STACK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "============================================"
echo "  Stack update"
echo "============================================"
echo ""

# ═══════════════════════════════════════
# 1. GIT PULL (the repo itself)
# ═══════════════════════════════════════

echo ">>> 1/15 Repository..."
cd "$STACK_DIR"
git pull --ff-only 2>/dev/null && echo "  Repository updated" || echo "  Repository already up to date or error"
echo ""

# ═══════════════════════════════════════
# 2. HOMEBREW (stack packages only)
# ═══════════════════════════════════════

echo ">>> 2/15 Homebrew (stack packages only)..."
brew update
brew upgrade node python@3.12 gh ffmpeg ripgrep anomalyco/tap/opencode-v2 2>/dev/null || echo "  brew: some packages updated"
brew cleanup --prune=all --quiet 2>/dev/null
echo ""
echo ">>> 3/15 Apple (Command Line Tools, system updates)..."
# CLT is updated via softwareupdate (not via brew). An outdated CLT
# breaks building brew formulae from source (see the pkgconf incident).
CLT_PATH=$(xcode-select -p 2>/dev/null)
if [ -n "$CLT_PATH" ] && [ "$CLT_PATH" != "xcode-select: error: unable to get active developer directory..." ]; then
    CLT_VER=$(pkgutil --pkg-info=com.apple.pkg.CLTools_Executables 2>/dev/null | awk '/version:/ {print $2}')
    echo "  CLT: ${CLT_VER:-version unknown} ($CLT_PATH)"
else
    echo "  ⚠️ CLT not active — xcode-select --install"
fi
SU_LIST=$(softwareupdate --list 2>/dev/null)
CLT_LABEL=$(printf '%s' "$SU_LIST" | sed -n 's/.*Label: \(.*Command Line Tools[^,]*\).*/\1/p' | head -1)
if [ -n "$CLT_LABEL" ]; then
    echo "  CLT update available: $CLT_LABEL"
    if sudo -n true 2>/dev/null; then
        softwareupdate -i "$CLT_LABEL" --quiet 2>/dev/null && echo "  ✅ CLT updated" || echo "  ❌ CLT install failed — update manually"
    else
        echo "  ⚠️ sudo required — run manually: sudo softwareupdate -i \"$CLT_LABEL\""
    fi
else
    echo "  CLT: no updates"
fi
if printf '%s' "$SU_LIST" | grep -q "Label" && [ -z "$CLT_LABEL" ]; then
    echo "  ⚠️ macOS updates available — install in System Settings → Software Update"
fi
echo ""

# ═══════════════════════════════════════
# 3. EXTERNAL MCP REPOS
# ═══════════════════════════════════════

echo ">>> 4/15 External MCP repositories..."
for repo in paraview-mcp manim-mcp julia-mcp tldraw-mcp WolframLanguageForJupyter; do
    if [ -d "$STACK_DIR/$repo" ]; then
        (cd "$STACK_DIR/$repo" && git pull --ff-only 2>/dev/null && echo "  $repo: updated" || echo "  $repo: up to date or error")
    else
        echo "  $repo: not found, skipping"
    fi
done
echo ""

# ═══════════════════════════════════════
# 4. TLDRAW MCP BUILD
# ═══════════════════════════════════════

echo ">>> 5/15 tldraw MCP build..."
if [ -d "$STACK_DIR/tldraw-mcp" ]; then
    cd "$STACK_DIR/tldraw-mcp"
    npm install --silent || echo "  npm install: error (check the network)"
    npm run build --silent || echo "  npm build: error"
    echo "  tldraw-mcp built"
else
    echo "  tldraw-mcp: not found, skipping"
fi
echo ""

# ═══════════════════════════════════════
# 5. PYTHON VENVS (4)
# ═══════════════════════════════════════

echo ">>> 6/15 Python venv..."

update_venv() {
    local name=$1; shift
    local dir="$STACK_DIR/$name"
    if [ ! -d "$dir" ]; then
        echo "  $name: not found, skipping"
        return
    fi
    source "$dir/bin/activate"
    pip install --upgrade --quiet "$@" 2>/dev/null
    deactivate
    echo "  $name: updated"
}

update_venv manim-env manim manimgl
update_venv jupyter-env jupyterlab numpy matplotlib pandas sympy plotly ipywidgets openpyxl markitdown

# ParaView MCP venv
if [ -d "$STACK_DIR/paraview-mcp-env" ]; then
    source "$STACK_DIR/paraview-mcp-env/bin/activate"
    pip install --upgrade --quiet -r "$STACK_DIR/paraview-mcp/requirements.txt" 2>/dev/null
    pip install --quiet "mcp[cli]<2" "anyio[asyncio]<5" 2>/dev/null
    deactivate
    # Re-apply ParaView MCP patches (git pull restores upstream code)
    sed -i '' 's/FastMCP("ParaView", system_prompt=default_prompt)/FastMCP("ParaView", instructions=default_prompt)/' \
        "$STACK_DIR/paraview-mcp/paraview_mcp_server.py" 2>/dev/null || true
    cp "$STACK_DIR/paraview-mcp-env/lib/python3.12/site-packages/typing_extensions.py" \
        "$STACK_DIR/paraview-mcp/typing_extensions.py" 2>/dev/null || true
    echo "  paraview-mcp-env: updated (patches applied)"
else
    echo "  paraview-mcp-env: not found, skipping"
fi

# Julia MCP venv
if [ -d "$STACK_DIR/julia-mcp-env" ]; then
    source "$STACK_DIR/julia-mcp-env/bin/activate"
    pip install --upgrade --quiet "mcp[cli]" 2>/dev/null
    deactivate
    echo "  julia-mcp-env: updated"
else
    echo "  julia-mcp-env: not found, skipping"
fi
echo ""

# ═══════════════════════════════════════
# 6. NPM GLOBAL CLI
# ═══════════════════════════════════════

echo ">>> 7/15 npm global CLI..."
npm install -g --allow-scripts=puppeteer firecrawl-cli@latest @kitschpatrol/tldraw-cli@latest || echo "  npm: partial update (sudo may be needed, or check the network)"
echo "  firecrawl-cli: $(firecrawl --version 2>/dev/null || echo 'not installed')"
echo "  tldraw CLI: $(tldraw --version 2>/dev/null || echo 'not installed')"

# Firecrawl: update skills (core + build + workflows) from the fresh CLI.
# Installed into temporary global directories — consolidate-skills.sh (step 8)
# moves them into $STACK_DIR/skills-store and cleans the global directories.
echo "  Firecrawl skills..."
firecrawl setup skills >/dev/null 2>&1 || true
firecrawl setup build >/dev/null 2>&1 || true
firecrawl setup workflows >/dev/null 2>&1 || true

# Chrome for tldraw export — version comes from the pin of the installed tldraw-cli
CHROME_VER=$(bash "$STACK_DIR/chrome-version.sh" 2>/dev/null)
if [ -n "$CHROME_VER" ]; then
    if ls ~/.cache/puppeteer/chrome/ 2>/dev/null | grep -q "$CHROME_VER"; then
        echo "  Chrome $CHROME_VER: already installed"
    else
        echo "  Chrome $CHROME_VER: installing for tldraw export..."
        npx -y puppeteer browsers install "chrome@$CHROME_VER" 2>/dev/null || echo "  Chrome: install skipped"
    fi
else
    echo "  Chrome: tldraw-cli not found, skipping"
fi
echo ""

# ═══════════════════════════════════════
# 8. VS CODE EXTENSIONS
# ═══════════════════════════════════════

echo ">>> 8/15 VS Code extensions..."
if command -v code >/dev/null 2>&1; then
    code --update-extensions >/dev/null 2>&1 && echo "  Extensions: updated" || echo "  Extensions: update skipped"
    echo "  VS Code updates itself automatically (self-update)"
else
    echo "  code CLI not found, skipping"
fi
echo ""

# ═══════════════════════════════════════
# 7. ARIS SKILLS (list from aris-skills.txt)
# ═══════════════════════════════════════

echo ">>> 9/15 ARIS skills..."
if [ -d "$STACK_DIR/aris-research-repo" ]; then
    bash "$STACK_DIR/sync-aris.sh" --update || echo "  ARIS: sync skipped"
else
    echo "  ARIS: clone not found, skipping"
fi
echo ""

# ═══════════════════════════════════════
# 8. STANDALONE SKILLS
# ═══════════════════════════════════════

echo ">>> 10/15 Skills (assemble into $STACK_DIR/skills-store)..."
bash "$STACK_DIR/consolidate-skills.sh" || echo "  Consolidation: skipped"
echo ""

# ═══════════════════════════════════════
# 9. JULIA (environment migration + IJulia)
# ═══════════════════════════════════════

echo ">>> 11/15 Julia..."

# Remember the current environment
OLD_ENV=""
for d in ~/.julia/environments/v*; do
    [ -d "$d" ] && OLD_ENV="$d"
done

juliaup update 2>/dev/null

# Determine the new Julia version
JULIA_VER=$(julia -e 'println(VERSION.major, ".", VERSION.minor)' 2>/dev/null)
NEW_ENV="$HOME/.julia/environments/v$JULIA_VER"

# Ensure the new environment exists: after juliaup update the
# v$JULIA_VER directory is not yet created — without this the migration
# would be silently skipped.
mkdir -p "$NEW_ENV"
if [ ! -f "$NEW_ENV/Project.toml" ]; then
    printf '\n' > "$NEW_ENV/Project.toml"   # empty manifest (no [deps] section)
fi

# If the environment is new (empty) — migrate packages from the old one
if [ -d "$NEW_ENV" ] && [ -n "$OLD_ENV" ] && [ "$OLD_ENV" != "$NEW_ENV" ]; then
    if grep -q "^\[" "$NEW_ENV/Project.toml" 2>/dev/null; then
        echo "  Julia v$JULIA_VER environment already contains packages"
    elif grep -q "^\[" "$OLD_ENV/Project.toml" 2>/dev/null; then
        echo "  Migrating packages: $(basename "$OLD_ENV") → $(basename "$NEW_ENV")"
        # Extract package names from the [deps] section and build a Julia array
        PACKAGES_JL=$(python3 - "$OLD_ENV/Project.toml" << 'PYEOF'
import sys
with open(sys.argv[1]) as f:
    content = f.read()
packages = []
in_deps = False
for line in content.split('\n'):
    line = line.strip()
    if line.startswith('['):
        in_deps = line == '[deps]'
        continue
    if in_deps and '=' in line:
        name = line.split('=')[0].strip().strip('"')
        if name:
            packages.append(name)
print('[' + ', '.join('"' + p + '"' for p in packages) + ']')
PYEOF
)
        if [ -n "$PACKAGES_JL" ] && [ "$PACKAGES_JL" != "[]" ]; then
            echo "  Migrating: $PACKAGES_JL"
            julia -e "using Pkg; Pkg.add($PACKAGES_JL)" 2>/dev/null || echo "  Migration: skipped (error)"
        fi
    fi
fi

# Update packages in the current environment
julia -e 'using Pkg; Pkg.update()' 2>/dev/null || echo "  Julia packages: update skipped"

# Check and build IJulia if needed
julia -e '
try
    using IJulia
    println("  IJulia: OK")
catch
    println("  IJulia: building and registering kernel...")
    using Pkg
    Pkg.build("IJulia")
    using IJulia
    installkernel("Julia $(Base.VERSION.major).$(Base.VERSION.minor)")
    println("  IJulia kernel installed")
end
' 2>/dev/null || echo "  IJulia: skipped"
echo ""

# ═══════════════════════════════════════
# 10. WOLFRAM
# ═══════════════════════════════════════

echo ">>> 12/15 Wolfram..."
WOLFRAM_VER=$(wolframscript -code 'p = PacletInstall["Wolfram/AgentTools"]; Print[p["Version"]]' 2>/dev/null | head -1)
if [ -n "$WOLFRAM_VER" ]; then
    echo "  AgentTools: $WOLFRAM_VER"
    WLIC=$(wolframscript -code 'Print[$LicenseExpirationDate]' 2>/dev/null | grep -oE '\{[0-9, ]+\}' | head -1 | tr -d '{}' | tr ',' ' ')
    WYEAR=$(echo $WLIC | awk '{print $1}'); WMONTH=$(echo $WLIC | awk '{print $2}'); WDAY=$(echo $WLIC | awk '{print $3}')
    if [ -n "$WYEAR" ]; then
        WEXP=$(date -j -f "%Y-%m-%d" "$WYEAR-$(printf '%02d' $WMONTH)-$(printf '%02d' $WDAY)" +%s 2>/dev/null)
        WDAYS=$(( ($WEXP - $(date +%s)) / 86400 ))
        if [ "$WDAYS" -lt 0 ]; then
            echo "  ⚠️ Wolfram license EXPIRED — the MCP will not connect! Renew: https://www.wolfram.com/engine/ and run wolframscript -activate"
        elif [ "$WDAYS" -lt 14 ]; then
            echo "  ⚠️ Wolfram license: $WDAYS days — renew: https://www.wolfram.com/engine/"
        else
            echo "  Wolfram license: $WDAYS days"
        fi
    fi
else
    echo "  Wolfram: update skipped (check the license)"
fi
echo ""

# Craft Apps (WordCraft, GridCraft, DeckCraft, PdfCraft, FigCraft): compare
# the installed version with the latest GitHub release. GUI updates go
# through craft-install.sh — here only checking + headless CLI.
echo "  Craft Apps..."
for repo in wordcraft gridcraft deckcraft pdfcraft figcraft; do
    case "$repo" in
        wordcraft) APP_NAME="WordCraft" ;;
        gridcraft) APP_NAME="GridCraft" ;;
        deckcraft) APP_NAME="DeckCraft" ;;
        pdfcraft)  APP_NAME="PdfCraft" ;;
        figcraft)  APP_NAME="FigCraft" ;;
    esac
    INSTALLED=""
    [ -d "/Applications/$APP_NAME.app" ] && \
        INSTALLED=$(defaults read "/Applications/$APP_NAME.app/Contents/Info.plist" CFBundleShortVersionString 2>/dev/null)
    LATEST=$(curl -s --max-time 20 "https://api.github.com/repos/storytold/$repo/releases/latest" \
        | grep -o '"tag_name": "[^"]*"' | cut -d'"' -f4 | sed 's/^v//')
    if [ -z "$INSTALLED" ]; then
        echo "  $APP_NAME: not installed (install: bash $STACK_DIR/scripts/craft-install.sh)"
    elif [ -n "$LATEST" ] && [ "$INSTALLED" != "$LATEST" ]; then
        echo "  $APP_NAME: $INSTALLED → $LATEST available — update: bash $STACK_DIR/scripts/craft-install.sh"
    else
        echo "  $APP_NAME: $INSTALLED up to date"
    fi
    # Headless CLI: sync with the fresh release (installs/updates when
    # it differs from $LATEST)
    CLIBIN="$STACK_DIR/craft-cli/$repo-cli"
    CLIVER="$LATEST"
    NEED_CLI=0
    [ ! -x "$CLIBIN" ] && NEED_CLI=1
    if [ -x "$CLIBIN" ] && [ -n "$CLIVER" ]; then
        CURCLI=$("$CLIBIN" --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')
        [ "$CURCLI" != "$CLIVER" ] && NEED_CLI=1
    fi
    if [ "$NEED_CLI" = "1" ] && [ -n "$CLIVER" ]; then
        TMPZIP="/tmp/$repo-cli-$CLIVER.zip"
        if curl -sL --max-time 600 -o "$TMPZIP" \
            "https://github.com/storytold/$repo/releases/download/v$CLIVER/$repo-cli-$CLIVER-macos-universal.zip"; then
            rm -rf "$STACK_DIR/craft-cli/$repo-cli-$CLIVER-macos-universal"
            unzip -q -o "$TMPZIP" -d "$STACK_DIR/craft-cli/" \
                && ln -sfn "$repo-cli-$CLIVER-macos-universal/$repo-cli" "$CLIBIN" \
                && chmod +x "$STACK_DIR/craft-cli/$repo-cli-$CLIVER-macos-universal/$repo-cli" \
                && echo "  $APP_NAME CLI: installed/updated to $CLIVER"
            rm -f "$TMPZIP"
        else
            echo "  $APP_NAME CLI: download failed"
        fi
    fi
done
# ── Firecrawl: account credits (refresh monthly) ──
echo "  Firecrawl credits..."
FC=$(firecrawl credits 2>/dev/null | grep -m1 "Remaining Credits" | grep -o "[0-9,]\+" | tr -d ',')
if [ -n "$FC" ]; then
    echo "  Firecrawl: $FC credits left"
    [ "$FC" -lt 100 ] 2>/dev/null && echo "  ⚠️ credits running out — without login only the free tier works"
else
    echo "  Firecrawl credits: could not get (not logged in?)"
fi

# ── ISP proxy subscription expiry ──
echo "  Proxy..."
bash "$STACK_DIR/scripts/proxy.sh" expiry 2>/dev/null || echo "  ⚠️ proxy check failed"
echo ""

# ═══════════════════════════════════════
# 11. CHECK
# ═══════════════════════════════════════

echo ">>> 13/15 Stack check..."
bash "$STACK_DIR/scripts/check-all.sh"

# ═══════════════════════════════════════
# 12. AGENTS.md SYNC
# ═══════════════════════════════════════

echo ""
echo ">>> 14/15 AGENTS.md sync..."
bash "$STACK_DIR/scripts/sync-agents.sh" --no-hint

# ═══════════════════════════════════════
# 13. FINAL
# ═══════════════════════════════════════

echo ""
echo ">>> 15/15 Final..."
echo "============================================"
echo "  Update complete!"
echo "============================================"
echo ""
echo "⚠️  Restart OpenCode to apply the changes:"
echo "  1. Close all open OpenCode sessions"
echo "  2. Start again: cd ~/project && opencode"
echo ""
