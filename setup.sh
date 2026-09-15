#!/bin/bash
set -euo pipefail

STACK_DIR="$HOME/stack"

echo "============================================"
echo "  Установка стека"
echo "============================================"
echo ""

# ═══════════════════════════════════════
# 1. СИСТЕМНЫЕ ЗАВИСИМОСТИ
# ═══════════════════════════════════════

echo ">>> 1/11 Homebrew..."
if ! command -v brew &>/dev/null; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

echo ">>> Homebrew пакеты..."
brew install python@3.12 node julia

# ═══════════════════════════════════════
# 2. ВНЕШНИЕ MCP РЕПОЗИТОРИИ
# ═══════════════════════════════════════

echo ">>> 2/11 Клонирование MCP серверов..."
cd "$STACK_DIR"

clone_if_missing() {
    local url=$1 dir=$2
    if [ ! -d "$dir" ]; then
        git clone --depth 1 "$url" "$dir"
    else
        echo "  $dir уже существует, пропускаю"
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

echo ">>> 3/11 Python venv..."

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
    echo "  $name готов"
}

create_venv manim-env manim manimgl
create_venv jupyter-env jupyterlab numpy matplotlib pandas sympy plotly ipywidgets openpyxl markitdown

# ParaView MCP venv
if [ ! -d "$STACK_DIR/paraview-mcp-env" ]; then
    python3.12 -m venv "$STACK_DIR/paraview-mcp-env"
fi
source "$STACK_DIR/paraview-mcp-env/bin/activate"
pip install --upgrade pip
pip install -r "$STACK_DIR/paraview-mcp/requirements.txt"
deactivate
echo "  paraview-mcp-env готов"

# Julia MCP venv
if [ ! -d "$STACK_DIR/julia-mcp-env" ]; then
    python3.12 -m venv "$STACK_DIR/julia-mcp-env"
fi
source "$STACK_DIR/julia-mcp-env/bin/activate"
pip install --upgrade pip
pip install "mcp[cli]"
deactivate
echo "  julia-mcp-env готов"

# ═══════════════════════════════════════
# 4. NODE.JS ЗАВИСИМОСТИ
# ═══════════════════════════════════════

echo ">>> 4/11 tldraw MCP..."
cd "$STACK_DIR/tldraw-mcp"
npm install
npm run build

# ═══════════════════════════════════════
# 5. GLOBAЛЬНЫЕ CLI
# ═══════════════════════════════════════

echo ">>> 5/11 CLI инструменты..."

echo "  Firecrawl CLI..."
npx -y firecrawl-cli@latest init -y --browser

echo "  tldraw CLI..."
npm install -g @kitschpatrol/tldraw-cli

# ═══════════════════════════════════════
# 6. BROWSER ДЛЯ RENDERS
# ═══════════════════════════════════════

echo ">>> 6/11 Browser для render-visual и tldraw export..."
echo "  Installing Playwright Chromium..."
npx -y playwright install chromium 2>/dev/null || echo "  Playwright: установи вручную (npx playwright install chromium)"
echo "  Installing Puppeteer Chrome..."
npx -y puppeteer browsers install chrome@152.0.7977.75 2>/dev/null || echo "  Puppeteer: установи вручную (npx puppeteer browsers install chrome@152.0.7977.75)"

# ═══════════════════════════════════════
# 7. SKILLS
# ═══════════════════════════════════════

echo ">>> 7/11 Skills..."
mkdir -p "$HOME/.config/opencode/skills"

# 7a. Firecrawl skills (28) — уже установлены через firecrawl-cli init

# 7b. ARIS skills (14) — из cloned repo
if [ -d "$STACK_DIR/aris-research-repo/skills" ]; then
    cp -r "$STACK_DIR/aris-research-repo/skills/"* "$HOME/.config/opencode/skills/" 2>/dev/null || true
    echo "  ARIS skills скопированы"
fi

# 7c. tldraw-skill — из GitHub
if [ ! -d "$HOME/.config/opencode/skills/tldraw-skill" ]; then
    git clone --depth 1 https://github.com/Agents365-ai/tldraw-skill.git /tmp/tldraw-skill-repo 2>/dev/null
    cp -r /tmp/tldraw-skill-repo "$HOME/.config/opencode/skills/tldraw-skill"
    rm -rf /tmp/tldraw-skill-repo
    echo "  tldraw-skill установлен"
else
    echo "  tldraw-skill уже существует"
fi

# 7d. Standalone skills (8) — из репозитория
cp -r "$STACK_DIR/skills/"* "$HOME/.config/opencode/skills/"
echo "  Standalone skills скопированы"

# ═══════════════════════════════════════
# 8. JULIA ПАКЕТЫ
# ═══════════════════════════════════════

echo ">>> 8/11 Julia пакеты..."
julia -e '
using Pkg
Pkg.add([
    "LinearAlgebra", "SparseArrays", "Plots", "DifferentialEquations",
    "StaticArrays", "Optim", "JuMP", "IJulia", "Flux", "Turing",
    "DataFrames", "CSV", "ForwardDiff", "SymPy", "SpecialFunctions",
    "StatsBase", "Distributions", "Polynomials", "FFTW", "IterativeSolvers"
])
' 2>/dev/null || echo "  Julia: установка пакетов пропущена (повтори вручную: julia → Pkg.add(...))"

# ═══════════════════════════════════════
# 9. OPENCODE КОНФИГ
# ═══════════════════════════════════════

echo ">>> 9/11 Генерация opencode.jsonc..."
mkdir -p "$HOME/.config/opencode"

python3 << 'PYEOF'
import os, json

home = os.path.expanduser("~")
stack = os.path.join(home, "stack")

config = {
    "$schema": "https://opencode.ai/config.json",
    "plugin": ["opencode-firecrawl"],
    "mcp": {
        "Wolfram": {
            "type": "local",
            "command": [
                "/Applications/Wolfram Engine.app/Contents/Resources/Wolfram Player.app/Contents/MacOS/wolfram",
                "-run",
                'PacletSymbol["Wolfram/AgentTools","Wolfram`AgentTools`StartMCPServer"][]',
                "-noinit", "-noprompt"
            ],
            "enabled": True,
            "environment": {
                "MCP_SERVER_NAME": "WolframLanguage",
                "WOLFRAM_BASE": "/Library/WolframEngine",
                "WOLFRAM_LOCALBASE": os.path.join(home, ".local/Wolfram/Objects"),
                "WOLFRAM_USERBASE": os.path.join(home, ".local/WolframEngine")
            },
            "timeout": 60000
        },
        "julia": {
            "type": "local",
            "command": [os.path.join(stack, "julia-mcp-env/bin/python"),
                        os.path.join(stack, "julia-mcp/server.py")],
            "enabled": True, "timeout": 60000
        },
        "manim": {
            "type": "local",
            "command": [os.path.join(stack, "manim-env/bin/python"),
                        os.path.join(stack, "manim-mcp/src/manim_server.py")],
            "enabled": True, "timeout": 120000
        },
        "ParaView": {
            "type": "local",
            "command": [os.path.join(stack, "paraview-mcp-env/bin/python"),
                        os.path.join(stack, "paraview-mcp/paraview_mcp_server.py")],
            "enabled": True, "timeout": 60000
        },
        "tldraw": {
            "type": "local",
            "command": ["node", os.path.join(stack, "tldraw-mcp/dist/index.js")],
            "enabled": True, "timeout": 60000
        }
    }
}

path = os.path.join(home, ".config/opencode/opencode.jsonc")
with open(path, "w") as f:
    json.dump(config, f, indent=2)
print(f"  Written to {path}")
PYEOF

# ═══════════════════════════════════════
# 10. АЛИАСЫ В .zshrc
# ═══════════════════════════════════════

echo ">>> 10/11 Алиасы..."
if ! grep -q "Stack Aliases" "$HOME/.zshrc" 2>/dev/null; then
    cat >> "$HOME/.zshrc" << 'ALIASES'

# === Stack Aliases ===
alias manim-activate="source ~/stack/manim-env/bin/activate"
alias jupyter-jlab="source ~/stack/jupyter-env/bin/activate && jupyter-lab"
alias jupyter-wolfram='source ~/stack/jupyter-env/bin/activate && jupyter-lab --NotebookApp.kernel_manager_class='"'"'jupyter_client.manager.KernelManager'"'"' --NotebookApp.kernel_name=wolframlanguage15'
alias stack="cd ~/stack"
alias new-project="~/stack/new-project.sh"
# === End Stack Aliases ===
ALIASES
    echo "  Алиасы добавлены в .zshrc"
else
    echo "  Алиасы уже есть в .zshrc"
fi

# ═══════════════════════════════════════
# 11. ПРОВЕРКА
# ═══════════════════════════════════════

echo ""
echo ">>> 11/11 Проверка стека..."
bash "$STACK_DIR/check-all.sh"

echo ""
echo "============================================"
echo "  Установка завершена!"
echo "============================================"
echo ""
echo "Ручные шаги (если ещё не сделаны):"
echo "  1. OpenCode: https://opencode.ai"
echo "  2. Wolfram Engine: brew install --cask wolfram-engine"
echo "     Затем: wolframscript (для активации лицензии)"
echo "  3. ParaView: https://www.paraview.org/download/"
echo "  4. Firecrawl: firecrawl login --browser (для полного функционала)"
echo ""
echo "Начать:"
echo "  cd ~/stack && opencode"
