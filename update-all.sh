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
# 2. HOMEBREW (только стек-пакеты)
# ═══════════════════════════════════════

echo ">>> 2/13 Homebrew (только стек-пакеты)..."
brew update
brew upgrade node python@3.12 gh ffmpeg anomalyco/tap/opencode 2>/dev/null || echo "  brew: часть пакетов обновлена"
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
# 9. JULIA (миграция окружения + IJulia)
# ═══════════════════════════════════════

echo ">>> 9/13 Julia..."

# Запоминаем текущее окружение
OLD_ENV=""
for d in ~/.julia/environments/v*; do
    [ -d "$d" ] && OLD_ENV="$d"
done

juliaup update 2>/dev/null

# Определяем новую версию Julia
JULIA_VER=$(julia -e 'println(VERSION.major, ".", VERSION.minor)' 2>/dev/null)
NEW_ENV="$HOME/.julia/environments/v$JULIA_VER"

# Если окружение новое (пустое) — мигрируем пакеты из старого
if [ -d "$NEW_ENV" ] && [ -n "$OLD_ENV" ] && [ "$OLD_ENV" != "$NEW_ENV" ]; then
    if grep -q "^\s*\[" "$NEW_ENV/Project.toml" 2>/dev/null; then
        echo "  Julia v$JULIA_VER окружение уже содержит пакеты"
    elif grep -q "^\s*\[" "$OLD_ENV/Project.toml" 2>/dev/null; then
        echo "  Миграция пакетов: $(basename "$OLD_ENV") → $(basename "$NEW_ENV")"
        # Извлекаем имена пакетов из старого Project.toml
        PACKAGES=$(grep -oP '^\s*\[\K[a-zA-Z0-9]+' "$OLD_ENV/Project.toml" | tr -d '[]' | while read -r uuid; do
            grep -B1 "$uuid" "$OLD_ENV/Project.toml" 2>/dev/null | grep '"' | tr -d '" '
        done | sort -u | grep -v "^$")
        if [ -n "$PACKAGES" ]; then
            julia -e "
using Pkg
pkgs = String[]
for line in split(raw\"$PACKAGES\", '\n')
    s = strip(line)
    isempty(s) || push!(pkgs, s)
end
unique!(pkgs)
println(\"  Переношу пакеты: \", join(pkgs, \", \"))
Pkg.add(pkgs)
" 2>/dev/null || echo "  Миграция: пропущена (ошибка)"
        fi
    fi
fi

# Обновляем пакеты в текущем окружении
julia -e 'using Pkg; Pkg.update()' 2>/dev/null || echo "  Julia packages: обновление пропущено"

# Проверяем и собираем IJulia если нужно
julia -e '
try
    using IJulia
    println("  IJulia: OK")
catch
    println("  IJulia: собираю и регистрирую kernel...")
    using Pkg
    Pkg.build("IJulia")
    using IJulia
    installkernel("Julia $(Base.VERSION.major).$(Base.VERSION.minor)")
    println("  IJulia kernel установлен")
end
' 2>/dev/null || echo "  IJulia: пропущен"
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
