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

echo ">>> 1/12 Homebrew..."
if ! command -v brew &>/dev/null; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

echo ">>> Homebrew пакеты..."
brew install python@3.12 node gh ffmpeg juliaup

# Julia — через juliaup (не brew-julia: вся документация и check-all.sh
# рассчитаны на ~/.juliaup/bin). release = актуальная стабильная версия.
juliaup add release 2>/dev/null || echo "  Julia release уже установлен"
juliaup default release 2>/dev/null || echo "  Julia default уже настроен"

# Wolfram AgentTools (paclet) — сразу, если Wolfram Engine уже установлен;
# иначе поставится update-all.sh (шаг 10) после ручной установки Wolfram.
if command -v wolframscript &>/dev/null; then
    wolframscript -code 'PacletInstall["Wolfram/AgentTools"]' >/dev/null 2>&1 \
        && echo "  Wolfram AgentTools: установлен" \
        || echo "  Wolfram AgentTools: не установился (повтори через update-all.sh)"
else
    echo "  Wolfram Engine ещё не установлен — AgentTools поставится в update-all.sh"
fi

# ═══════════════════════════════════════
# 2. ВНЕШНИЕ MCP РЕПОЗИТОРИИ
# ═══════════════════════════════════════

echo ">>> 2/12 Клонирование MCP серверов..."
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

echo ">>> 4/12 tldraw MCP..."
cd "$STACK_DIR/tldraw-mcp"
npm install
npm run build

# ═══════════════════════════════════════
# 5. GLOBAЛЬНЫЕ CLI
# ═══════════════════════════════════════

echo ">>> 5/12 CLI инструменты..."

echo "  Firecrawl CLI..."
npx -y firecrawl-cli@latest init -y --browser || echo "  Firecrawl: init пропущен (выполни вручную: firecrawl init)"

echo "  tldraw CLI..."
npm install -g --allow-scripts=puppeteer @kitschpatrol/tldraw-cli

# ═══════════════════════════════════════
# 6. BROWSER ДЛЯ RENDERS
# ═══════════════════════════════════════

echo ">>> 6/12 Browser для render-visual и tldraw export..."
echo "  Installing Playwright Chromium..."
npx -y playwright install chromium 2>/dev/null || echo "  Playwright: установи вручную (npx playwright install chromium)"
echo "  Installing Puppeteer Chrome..."
CHROME_VER=$(bash "$STACK_DIR/chrome-version.sh" 2>/dev/null)
if [ -n "$CHROME_VER" ]; then
    npx -y puppeteer browsers install "chrome@$CHROME_VER" 2>/dev/null || echo "  Puppeteer: установи вручную (npx puppeteer browsers install chrome@$CHROME_VER)"
else
    echo "  tldraw-cli не установлен — Chrome пропущен (поставится при обновлении)"
fi

# ═══════════════════════════════════════
# 7. CRAFT APPS CLI (офисные документы)
# ═══════════════════════════════════════

echo ">>> 7/12 Craft Apps CLI (headless, для MCP-серверов wordcraft/gridcraft/deckcraft/pdfcraft)..."
mkdir -p "$STACK_DIR/craft-cli"
CRAFT_CLI_VERSIONS="wordcraft=0.18.1 gridcraft=0.19.1 deckcraft=0.18.1 pdfcraft=0.21.1"
for kv in $CRAFT_CLI_VERSIONS; do
    name=${kv%%=*}; ver=${kv##*=}
    BIN="$STACK_DIR/craft-cli/$name-cli"
    if [ ! -e "$BIN" ]; then
        TMPZIP="/tmp/$name-cli-$ver.zip"
        curl -sL --max-time 600 -o "$TMPZIP" \
            "https://github.com/storytold/$name/releases/download/v$ver/$name-cli-$ver-macos-universal.zip" \
        && rm -rf "$STACK_DIR/craft-cli/$name-cli-$ver-macos-universal" \
        && unzip -q -o "$TMPZIP" -d "$STACK_DIR/craft-cli/" \
        && ln -sfn "$name-cli-$ver-macos-universal/$name-cli" "$BIN" \
        && chmod +x "$STACK_DIR/craft-cli/$name-cli-$ver-macos-universal/$name-cli" \
        && echo "  $name-cli: установлен (v$ver)" \
        || echo "  $name-cli: не скачался (скачай $name-cli-*.zip с github.com/storytold/$name/releases)"
        rm -f "$TMPZIP"
    else
        echo "  $name-cli: уже есть"
    fi
done
echo "  GUI-приложения (WordCraft, GridCraft, DeckCraft, PdfCraft) ставятся вручную через ArtCraft Launcher — см. README «Ручные шаги»"
echo ""

# ═══════════════════════════════════════
# 8. VS CODE РАСШИРЕНИЯ
# ═══════════════════════════════════════

echo ">>> 8/12 VS Code расширения..."
if command -v code &>/dev/null; then
    # Расширения стека: просмотр файлов (.tldr, .ipynb, .tex, .wl, .jl, .py)
    # и языковая поддержка. code --install-extension идемпотентен.
    for ext in \
        tldraw-org.tldraw-vscode \
        ms-python.python \
        ms-toolsai.jupyter \
        julialang.language-julia \
        wolframresearch.wolfram \
        james-yu.latex-workshop; do
        code --install-extension "$ext" --force >/dev/null 2>&1 \
            && echo "  $ext: ✅" \
            || echo "  $ext: ⚠️ не установилось (проверь VS Code CLI)"
    done
else
    echo "  VS Code CLI (code) не найден — пропускаю (установи VS Code и повтори)"
fi
echo ""

# ═══════════════════════════════════════
# 8. SKILLS (хранилище ~/stack/skills-store)
# ═══════════════════════════════════════

echo ">>> 9/12 Skills (консолидация в ~/stack/skills-store)..."
# Firecrawl-скиллы поставлены firecrawl-cli init (шаг 5) — переносятся
# в хранилище. Глобальные каталоги скиллов опустошаются: скиллы видны
# только в проектах (подключаются через skills.paths в конфиге).
if [ -d "$STACK_DIR/aris-research-repo" ]; then
    bash "$STACK_DIR/sync-aris.sh" || echo "  ARIS: синхронизация пропущена"
else
    echo "  ARIS: клон не найден, пропускаю"
fi
bash "$STACK_DIR/consolidate-skills.sh"

# ═══════════════════════════════════════
# 9. JULIA ПАКЕТЫ
# ═══════════════════════════════════════

echo ">>> 10/12 Julia пакеты..."
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
# 10. OPENCODE КОНФИГ (проектный)
# ═══════════════════════════════════════

echo ">>> 11/12 Генерация конфига OpenCode..."
# Стек поднимается ТОЛЬКО в проектах: конфиг пишется в .opencode/opencode.json
# папки стека. Проекты получают такой же конфиг через sync-agents.sh
# и new-project.sh. Глобальный ~/.config/opencode стек не использует.
bash "$STACK_DIR/gen-opencode-config.sh" "$STACK_DIR"

# ═══════════════════════════════════════
# 12. ПРОВЕРКА
# ═══════════════════════════════════════

echo ""
echo ">>> 12/12 Проверка стека..."
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
