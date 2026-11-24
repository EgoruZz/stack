#!/bin/bash
set -euo pipefail

STACK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "============================================"
echo "  Stack installation"
echo "============================================"
echo ""

# ═══════════════════════════════════════
# 1. SYSTEM DEPENDENCIES
# ═══════════════════════════════════════

echo ">>> 1/12 Homebrew..."
# Manifest of what was already installed before the stack — teardown.sh uses it
# to uninstall ONLY what the stack added (brew leaves list, formulae + casks).
if [ ! -f "$STACK_DIR/.brew-pre-manifest.txt" ]; then
    if command -v brew &>/dev/null; then
        { brew list --formula; echo "── casks:"; brew list --cask; } > "$STACK_DIR/.brew-pre-manifest.txt" 2>/dev/null
        echo "  Pre-install manifest saved (.brew-pre-manifest.txt)"
    fi
fi
if ! command -v brew &>/dev/null; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

echo ">>> Homebrew packages..."
brew install python@3.12 node gh ffmpeg juliaup

# GUI applications and large packages — official brew casks (auto-updated by cask).
# Guard: if an app was already installed manually (not via cask) — skip the cask,
# to avoid two copies (e.g. ParaView-6.2.0-RC1.app + ParaView.app).
echo ">>> Brew casks (GUI): wolfram-engine, paraview, mactex, tldraw..."
for pair in "wolfram-engine Wolfram" "paraview ParaView-" "mactex TeX" "tldraw tldraw"; do
    set -- $pair; cask=$1; appdir=$2
    if brew list --cask "$cask" &>/dev/null; then
        echo "  $cask: already installed (cask)"
    elif ls -d /Applications/"$appdir"* >/dev/null 2>&1; then
        echo "  $cask: app already installed manually — skipping cask (remove the manual copy if you want auto-updates)"
    elif brew install --cask "$cask" >/dev/null 2>&1; then
        echo "  $cask: ✅"
    else
        echo "  $cask: ⚠️ not installed — install manually: brew install --cask $cask"
    fi
done

# VS Code: official cask if the `code` CLI is unavailable (needed for stack extensions)
if ! command -v code &>/dev/null; then
    if brew install --cask visual-studio-code >/dev/null 2>&1; then
        echo "  visual-studio-code: ✅"
    else
        echo "  visual-studio-code: ⚠️ install manually: brew install --cask visual-studio-code"
    fi
else
    echo "  vscode: already installed"
fi

# OpenCode — official tap (update-all.sh updates the same package)
if ! command -v opencode &>/dev/null; then
    brew tap anomalyco/tap >/dev/null 2>&1
    if brew install anomalyco/tap/opencode-v2 >/dev/null 2>&1; then
        echo "  opencode: ✅"
    else
        echo "  opencode: ⚠️ install manually (https://opencode.ai)"
    fi
else
    echo "  opencode: already installed"
fi

# Julia — via juliaup (not brew-julia: all the documentation and check-all.sh
# expect ~/.juliaup/bin). release = current stable version.
juliaup add release 2>/dev/null || echo "  Julia release already installed"
juliaup default release 2>/dev/null || echo "  Julia default already configured"

# Stack networking: .zshrc must source proxy.sh (routing through the ISP proxy).
# Only this line is managed — the rest of the user's .zshrc is untouched.
# The stack requires zsh: without it .zshrc is never read at all.
if command -v zsh &>/dev/null; then
    [ -f "$HOME/.zshrc" ] || touch "$HOME/.zshrc"
    if ! grep -q "stack/proxy.sh" "$HOME/.zshrc" 2>/dev/null; then
        cat >> "$HOME/.zshrc" << 'PROXYBLOCK'

# === Stack network (managed; details: $STACK_DIR/proxy.sh) ===
export TZ="Asia/Singapore"
source "$STACK_DIR/proxy.sh"
# === End Stack network ===
PROXYBLOCK
        echo "  .zshrc: added source proxy.sh (restart the terminal)"
    else
        echo "  .zshrc: proxy.sh already connected"
    fi
else
    echo "  ⚠️ zsh not found — proxy block not added (the stack assumes zsh as the shell)"
fi

# Wolfram AgentTools (paclet) — immediately if Wolfram Engine is already installed;
# otherwise it will be installed by update-all.sh (step 10) after manual Wolfram install.
if command -v wolframscript &>/dev/null; then
    wolframscript -code 'PacletInstall["Wolfram/AgentTools"]' >/dev/null 2>&1 \
        && echo "  Wolfram AgentTools: installed" \
        || echo "  Wolfram AgentTools: not installed (retry via update-all.sh)"
else
    echo "  Wolfram Engine not yet installed — AgentTools will be installed in update-all.sh"
fi

# ═══════════════════════════════════════
# 2. EXTERNAL MCP REPOSITORIES
# ═══════════════════════════════════════

echo ">>> 2/12 Cloning MCP servers..."
cd "$STACK_DIR"

clone_if_missing() {
    local url=$1 dir=$2
    if [ ! -d "$dir" ]; then
        git clone --depth 1 "$url" "$dir"
    else
        echo "  $dir already exists, skipping"
    fi
}

clone_if_missing https://github.com/llnl/paraview_mcp.git          paraview-mcp
clone_if_missing https://github.com/abhiemj/manim-mcp-server.git    manim-mcp
clone_if_missing https://github.com/aplavin/julia-mcp.git           julia-mcp
clone_if_missing https://github.com/AndresMuelas2004/tldraw-mcp-server.git tldraw-mcp
clone_if_missing https://github.com/wanshuiyin/Auto-claude-code-research-in-sleep.git aris-research-repo
clone_if_missing https://github.com/WolframResearch/WolframLanguageForJupyter.git WolframLanguageForJupyter

# ═══════════════════════════════════════
# 3. PYTHON VENV
# ═══════════════════════════════════════

echo ">>> 3/12 Python venv..."

create_venv() {
    local name=$1; shift
    local dir="$STACK_DIR/$name"
    if [ ! -d "$dir" ]; then
        python3.12 -m venv "$dir"
    fi
    source "$dir/bin/activate"
    pip install --upgrade pip
    pip install "$@"
    deactivate
    echo "  $name ready"
}

create_venv manim-env manim manimgl "setuptools<81" "mcp[cli]<2" "anyio[asyncio]<5"
create_venv jupyter-env jupyterlab numpy matplotlib pandas sympy plotly ipywidgets openpyxl markitdown

# ParaView MCP venv
if [ ! -d "$STACK_DIR/paraview-mcp-env" ]; then
    python3.12 -m venv "$STACK_DIR/paraview-mcp-env"
fi
source "$STACK_DIR/paraview-mcp-env/bin/activate"
pip install --upgrade pip
pip install -r "$STACK_DIR/paraview-mcp/requirements.txt"
pip install "mcp[cli]<2" "anyio[asyncio]<5"
deactivate
echo "  paraview-mcp-env ready"
# ParaView MCP patches (see README «Known fixes» in AGENTS):
# 1) FastMCP API: system_prompt → instructions (mcp 1.x)
# 2) pvpython's bundled typing_extensions is too old for anyio — fresh copy in the repo dir
sed -i '' 's/FastMCP("ParaView", system_prompt=default_prompt)/FastMCP("ParaView", instructions=default_prompt)/' \
    "$STACK_DIR/paraview-mcp/paraview_mcp_server.py" || true
cp "$STACK_DIR/paraview-mcp-env/lib/python3.12/site-packages/typing_extensions.py" \
    "$STACK_DIR/paraview-mcp/typing_extensions.py" 2>/dev/null || true

# Julia MCP venv
if [ ! -d "$STACK_DIR/julia-mcp-env" ]; then
    python3.12 -m venv "$STACK_DIR/julia-mcp-env"
fi
source "$STACK_DIR/julia-mcp-env/bin/activate"
pip install --upgrade pip
pip install "mcp[cli]<2" "anyio[asyncio]<5"
deactivate
echo "  julia-mcp-env ready"

# ═══════════════════════════════════════
# 4. NODE.JS DEPENDENCIES
# ═══════════════════════════════════════

echo ">>> 4/12 tldraw MCP..."
cd "$STACK_DIR/tldraw-mcp"
npm install
npm run build

# ═══════════════════════════════════════
# 5. GLOBAL CLIs
# ═══════════════════════════════════════

echo ">>> 5/12 CLI tools..."

echo "  Firecrawl CLI..."
npx -y firecrawl-cli@latest init -y --browser || echo "  Firecrawl: init skipped (run manually: firecrawl init)"

# Firecrawl skills: installed into global directories; moved into
# skills-store by the consolidation (step 9)
firecrawl setup skills >/dev/null 2>&1 || true
firecrawl setup build >/dev/null 2>&1 || true
firecrawl setup workflows >/dev/null 2>&1 || true

echo "  tldraw CLI..."
npm install -g --allow-scripts=puppeteer @kitschpatrol/tldraw-cli

# ═══════════════════════════════════════
# 6. BROWSER FOR RENDERS
# ═══════════════════════════════════════

echo ">>> 6/12 Browser for render-visual and tldraw export..."
echo "  Installing Playwright Chromium..."
npx -y playwright install chromium 2>/dev/null || echo "  Playwright: install manually (npx playwright install chromium)"
echo "  Installing Puppeteer Chrome..."
CHROME_VER=$(bash "$STACK_DIR/chrome-version.sh" 2>/dev/null)
if [ -n "$CHROME_VER" ]; then
    npx -y puppeteer browsers install "chrome@$CHROME_VER" 2>/dev/null || echo "  Puppeteer: install manually (npx puppeteer browsers install chrome@$CHROME_VER)"
else
    echo "  tldraw-cli not installed — Chrome skipped (will be installed on update)"
fi

# ═══════════════════════════════════════
# 7. CRAFT APPS CLI (office documents)
# ═══════════════════════════════════════

echo ">>> 7/12 Craft Apps CLI (headless, for the wordcraft/gridcraft/deckcraft/pdfcraft/figcraft MCP servers)..."
mkdir -p "$STACK_DIR/craft-cli"
CRAFT_REPOS="wordcraft gridcraft deckcraft pdfcraft figcraft"
# Fallback in case the GitHub API is unavailable (update-all.sh will
# upgrade to the current versions itself later).
CRAFT_FALLBACK="wordcraft=0.18.1 gridcraft=0.19.1 deckcraft=0.18.1 pdfcraft=0.21.1 figcraft=0.18.1"
for name in $CRAFT_REPOS; do
    ver=$(curl -s --max-time 20 "https://api.github.com/repos/storytold/$name/releases/latest" \
        | grep -o '"tag_name": "[^"]*"' | cut -d'"' -f4 | sed 's/^v//')
    [ -z "$ver" ] && ver=$(printf '%s' "$CRAFT_FALLBACK" | tr ' ' '\n' | grep "^$name=" | cut -d= -f2)
    [ -z "$ver" ] && { echo "  $name-cli: could not determine version, skipping"; continue; }
    BIN="$STACK_DIR/craft-cli/$name-cli"
    if [ ! -e "$BIN" ]; then
        TMPZIP="/tmp/$name-cli-$ver.zip"
        curl -sL --max-time 600 -o "$TMPZIP" \
            "https://github.com/storytold/$name/releases/download/v$ver/$name-cli-$ver-macos-universal.zip" \
        && rm -rf "$STACK_DIR/craft-cli/$name-cli-$ver-macos-universal" \
        && unzip -q -o "$TMPZIP" -d "$STACK_DIR/craft-cli/" \
        && ln -sfn "$name-cli-$ver-macos-universal/$name-cli" "$BIN" \
        && chmod +x "$STACK_DIR/craft-cli/$name-cli-$ver-macos-universal/$name-cli" \
        && echo "  $name-cli: installed (v$ver)" \
        || echo "  $name-cli: download failed (download $name-cli-*.zip from github.com/storytold/$name/releases)"
        rm -f "$TMPZIP"
    else
        echo "  $name-cli: already present"
    fi
done
echo "  GUI apps (WordCraft, GridCraft, DeckCraft, PdfCraft, FigCraft): bash $STACK_DIR/craft-install.sh — see README «Manual steps»"
echo ""

# ═══════════════════════════════════════
# 8. VS CODE EXTENSIONS
# ═══════════════════════════════════════

echo ">>> 8/12 VS Code extensions..."
if command -v code &>/dev/null; then
    # Stack extensions: file viewing (.tldr, .ipynb, .tex, .wl, .jl, .py)
    # and language support. code --install-extension is idempotent.
    for ext in \
        tldraw-org.tldraw-vscode \
        ms-python.python \
        ms-toolsai.jupyter \
        julialang.language-julia \
        wolframresearch.wolfram \
        james-yu.latex-workshop; do
        code --install-extension "$ext" --force >/dev/null 2>&1 \
            && echo "  $ext: ✅" \
            || echo "  $ext: ⚠️ failed to install (check the VS Code CLI)"
    done
else
    echo "  VS Code CLI (code) not found — skipping (install VS Code and re-run)"
fi
echo ""

# ═══════════════════════════════════════
# 8. SKILLS (store: $STACK_DIR/skills-store)
# ═══════════════════════════════════════

echo ">>> 9/12 Skills (assemble into $STACK_DIR/skills-store)..."
# Firecrawl skills were installed by firecrawl-cli init (step 5) — moved
# into the store. Global skill directories are emptied: skills are visible
# only in projects (attached via skills.paths in the config).
if [ -d "$STACK_DIR/aris-research-repo" ]; then
    bash "$STACK_DIR/sync-aris.sh" || echo "  ARIS: sync skipped"
else
    echo "  ARIS: clone not found, skipping"
fi
bash "$STACK_DIR/consolidate-skills.sh"

# ═══════════════════════════════════════
# 9. JULIA PACKAGES
# ═══════════════════════════════════════

echo ">>> 10/12 Julia packages..."
julia -e '
using Pkg
Pkg.add([
    "LinearAlgebra", "SparseArrays", "Plots", "DifferentialEquations",
    "StaticArrays", "Optim", "JuMP", "IJulia", "Flux", "Turing",
    "DataFrames", "CSV", "ForwardDiff", "SymPy", "SpecialFunctions",
    "StatsBase", "Distributions", "Polynomials", "FFTW", "IterativeSolvers"
])
' 2>/dev/null || echo "  Julia: package install skipped (retry manually: julia → Pkg.add(...))"

# ═══════════════════════════════════════
# 10. OPENCODE CONFIG (project)
# ═══════════════════════════════════════

echo ">>> 11/12 Generating the OpenCode config..."
# The stack is attached ONLY in projects: the config is written to
# .opencode/opencode.json of the stack folder. Projects get the same config
# via sync-agents.sh and new-project.sh. The global ~/.config/opencode is used
# only for client settings (permission), NOT for MCP/skills.
bash "$STACK_DIR/gen-opencode-config.sh" "$STACK_DIR"

# ═══════════════════════════════════════
# 11b. GITHUB CLI + GLOBAL CLIENT CONFIG
# ═══════════════════════════════════════

echo ">>> 11b/12 GitHub CLI (scopes) and permission config..."
# The gh token needs full scopes — without them the agent cannot make PRs,
# delete/move repos, or work with organizations. Login is interactive and
# done ONCE per machine (the token lives in the keyring and survives restarts).
if ! command -v gh >/dev/null 2>&1; then
    echo "  gh not found, skipping"
elif ! gh auth status >/dev/null 2>&1; then
    echo "  gh not authenticated — starting login (once per machine)..."
    gh auth login -h github.com -p ssh -s repo -s admin:org -s workflow -s admin:public_key -s delete_repo -s gist || \
        echo "  ⚠️ login not completed — run later: gh auth login -s repo,admin:org,workflow,admin:public_key,delete_repo,gist"
elif ! gh auth status 2>&1 | grep -q "admin:org"; then
    echo "  token present but scopes incomplete — extending (device-flow)..."
    gh auth refresh -h github.com -s admin:org -s workflow || \
        echo "  ⚠️ failed — run later: gh auth refresh -s admin:org -s workflow"
else
    echo "  gh: authenticated, scopes complete"
fi
# Global OpenCode client config: permission allow — the agent is not asked
# to click "allow" on every action (these are client settings, not MCP/skills).
OC_DIR="$HOME/.config/opencode"; mkdir -p "$OC_DIR"
OC_CONF="$OC_DIR/opencode.jsonc"
if [ ! -f "$OC_CONF" ]; then
    cat > "$OC_CONF" << 'EOF'
{
  "$schema": "https://opencode.ai/config.json",
  "permission": {
    "edit": "allow",
    "webfetch": "allow",
    "bash": {
      "*": "allow"
    }
  }
}
EOF
    echo "  $OC_CONF: created (permission: allow)"
else
    echo "  $OC_CONF: already exists, not touching"
fi

# ═══════════════════════════════════════
# 12. CHECK
# ═══════════════════════════════════════

echo ""
echo ">>> 12/12 Stack check..."
bash "$STACK_DIR/check-all.sh"

echo ""
echo "============================================"
echo "  Installation complete!"
echo "============================================"
echo ""

# First-start form: if the user filled it in beforehand — apply it right away
if [ -f "$STACK_DIR/first-start.txt" ]; then
    echo ">>> Found a filled first-start form — applying..."
    bash "$STACK_DIR/apply-first-start.sh" "$STACK_DIR/first-start.txt" || \
        echo "  ⚠️ The form was not applied (incomplete — fix and re-run)"
fi

echo "Remaining setup (first-start form, Craft Apps GUI, Wolfram activation,"
echo "Firecrawl login, project attach) is guided by the AI agent:"
echo ""
echo "  cd \"$STACK_DIR\" && opencode"
echo ""
echo "Start a session here and tell the agent to set up the stack — it walks"
echo "through every step and asks for whatever it needs."
echo "Re-check any time: bash \"$STACK_DIR/check-all.sh\""
