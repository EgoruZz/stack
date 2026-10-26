#!/bin/bash
# Скрипт полного обновления всего стека
# Запуск: cd ~/stack && bash update-all.sh
# Обновляет: brew, внешние репозитории, tldraw-mcp, Python venv, npm CLI,
#            ARIS skills, standalone skills, Julia, Wolfram

set -uo pipefail

STACK_DIR="$HOME/stack"
SKILLS_DIR="$HOME/.config/opencode/skills"

echo "============================================"
echo "  Обновление стека"
echo "============================================"
echo ""

# ═══════════════════════════════════════
# 1. GIT PULL (сам репозиторий)
# ═══════════════════════════════════════

echo ">>> 1/13 Репозиторий..."
cd "$STACK_DIR"
git pull --ff-only 2>/dev/null && echo "  Репозиторий обновлён" || echo "  Репозиторий уже актуален или ошибка"
echo ""

# ═══════════════════════════════════════
# 2. HOMEBREW
# ═══════════════════════════════════════

echo ">>> 2/13 Homebrew..."
brew update && brew upgrade
echo ""

# ═══════════════════════════════════════
# 3. ВНЕШНИЕ MCP РЕПОЗИТОРИИ
# ═══════════════════════════════════════

echo ">>> 3/13 Внешние MCP репозитории..."
for repo in paraview-mcp manim-mcp julia-mcp tldraw-mcp WolframLanguageForJupyter; do
    if [ -d "$STACK_DIR/$repo" ]; then
        (cd "$STACK_DIR/$repo" && git pull --ff-only 2>/dev/null && echo "  $repo: обновлён" || echo "  $repo: актуален или ошибка")
    else
        echo "  $repo: не найден, пропускаю"
    fi
done
echo ""

# ═══════════════════════════════════════
# 4. TLDRAW MCP СБОРКА
# ═══════════════════════════════════════

echo ">>> 4/13 tldraw MCP сборка..."
if [ -d "$STACK_DIR/tldraw-mcp" ]; then
    cd "$STACK_DIR/tldraw-mcp"
    npm install --silent 2>/dev/null
    npm run build --silent 2>/dev/null
    echo "  tldraw-mcp собран"
else
    echo "  tldraw-mcp: не найден, пропускаю"
fi
echo ""

# ═══════════════════════════════════════
# 5. PYTHON VENV (4 шт.)
# ═══════════════════════════════════════

echo ">>> 5/13 Python venv..."

update_venv() {
    local name=$1; shift
    local dir="$STACK_DIR/$name"
    if [ ! -d "$dir" ]; then
        echo "  $name: не найден, пропускаю"
        return
    fi
    source "$dir/bin/activate"
    pip install --upgrade --quiet "$@" 2>/dev/null
    deactivate
    echo "  $name: обновлён"
}

update_venv manim-env manim manimgl
update_venv jupyter-env jupyterlab numpy matplotlib pandas sympy plotly ipywidgets openpyxl markitdown

# ParaView MCP venv
if [ -d "$STACK_DIR/paraview-mcp-env" ]; then
    source "$STACK_DIR/paraview-mcp-env/bin/activate"
    pip install --upgrade --quiet -r "$STACK_DIR/paraview-mcp/requirements.txt" 2>/dev/null
    deactivate
    echo "  paraview-mcp-env: обновлён"
else
    echo "  paraview-mcp-env: не найден, пропускаю"
fi

# Julia MCP venv
if [ -d "$STACK_DIR/julia-mcp-env" ]; then
    source "$STACK_DIR/julia-mcp-env/bin/activate"
    pip install --upgrade --quiet "mcp[cli]" 2>/dev/null
    deactivate
    echo "  julia-mcp-env: обновлён"
else
    echo "  julia-mcp-env: не найден, пропускаю"
fi
echo ""

# ═══════════════════════════════════════
# 6. NPM GLOBAL CLI
# ═══════════════════════════════════════

echo ">>> 6/13 npm global CLI..."
npm install -g --silent firecrawl-cli@latest @kitschpatrol/tldraw-cli@latest 2>/dev/null
echo "  firecrawl-cli: $(firecrawl --version 2>/dev/null || echo 'ошибка')"
echo "  tldraw CLI: $(tldraw --version 2>/dev/null || echo 'ошибка')"
echo ""

# ═══════════════════════════════════════
# 7. ARIS SKILLS
# ═══════════════════════════════════════

echo ">>> 7/13 ARIS skills..."
if [ -d "$STACK_DIR/aris-research-repo" ]; then
    (cd "$STACK_DIR/aris-research-repo" && git pull --ff-only 2>/dev/null && echo "  ARIS репо обновлён" || echo "  ARIS репо: актуален или ошибка")
    mkdir -p "$SKILLS_DIR"
    for skill in ablation-planner auto-review-loop experiment-bridge experiment-queue \
                 idea-creator idea-discovery novelty-check paper-writing render-html \
                 research-lit research-review run-experiment shared-references training-check; do
        if [ -d "$STACK_DIR/aris-research-repo/skills/$skill" ]; then
            rsync -a --delete "$STACK_DIR/aris-research-repo/skills/$skill/" "$SKILLS_DIR/$skill/" 2>/dev/null
        fi
    done
    echo "  ARIS skills синхронизированы"
else
    echo "  ARIS: не найден, пропускаю"
fi
echo ""

# ═══════════════════════════════════════
# 8. STANDALONE SKILLS
# ═══════════════════════════════════════

echo ">>> 8/13 Standalone skills..."
mkdir -p "$SKILLS_DIR"
cp -r "$STACK_DIR/skills/"* "$SKILLS_DIR/" 2>/dev/null
echo "  Standalone skills скопированы"
echo ""

# ═══════════════════════════════════════
# 9. JULIA
# ═══════════════════════════════════════

echo ">>> 9/13 Julia..."
juliaup update 2>/dev/null
julia -e 'using Pkg; Pkg.update()' 2>/dev/null || echo "  Julia packages: обновление пропущено"
echo ""

# ═══════════════════════════════════════
# 10. WOLFRAM
# ═══════════════════════════════════════

echo ">>> 10/13 Wolfram..."
wolframscript -code 'PacletUpdate[]' 2>/dev/null || echo "  Wolfram: обновление пропущено (проверь лицензию)"
echo ""

# ═══════════════════════════════════════
# 11. ПРОВЕРКА
# ═══════════════════════════════════════

echo ">>> 11/13 Проверка стека..."
bash "$STACK_DIR/check-all.sh"

# ═══════════════════════════════════════
# 12. СИНХРОНИЗАЦИЯ AGENTS.md
# ═══════════════════════════════════════

echo ""
echo ">>> 12/13 Синхронизация AGENTS.md..."
bash "$STACK_DIR/sync-agents.sh"

# ═══════════════════════════════════════
# 13. ФИНАЛ
# ═══════════════════════════════════════

echo ""
echo "============================================"
echo "  Обновление завершено!"
echo "============================================"
echo ""
echo "⚠️  ПЕРЕЗАПУСТИ OPENCODE ДЛЯ ПРИМЕНЕНИЯ ИЗМЕНЕНИЙ:"
echo "  1. Закрой все открытые сессии OpenCode"
echo "  2. Запусти заново: cd ~/проект && opencode"
echo ""
