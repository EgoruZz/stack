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
    npm install --silent || echo "  npm install: ошибка (проверь сеть)"
    npm run build --silent || echo "  npm build: ошибка"
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
npm install -g --allow-scripts=puppeteer firecrawl-cli@latest @kitschpatrol/tldraw-cli@latest || echo "  npm: обновление частичное (возможно нужен sudo или проверь сеть)"
echo "  firecrawl-cli: $(firecrawl --version 2>/dev/null || echo 'не установлен')"
echo "  tldraw CLI: $(tldraw --version 2>/dev/null || echo 'не установлен')"

# Chrome под tldraw export — версия берётся из пина установленного tldraw-cli
CHROME_VER=$(bash "$STACK_DIR/chrome-version.sh" 2>/dev/null)
if [ -n "$CHROME_VER" ]; then
    if ls ~/.cache/puppeteer/chrome/ 2>/dev/null | grep -q "$CHROME_VER"; then
        echo "  Chrome $CHROME_VER: уже установлен"
    else
        echo "  Chrome $CHROME_VER: устанавливаю под tldraw export..."
        npx -y puppeteer browsers install "chrome@$CHROME_VER" 2>/dev/null || echo "  Chrome: установка пропущена"
    fi
else
    echo "  Chrome: tldraw-cli не найден, пропускаю"
fi
echo ""

# ═══════════════════════════════════════
# 7. ARIS SKILLS (список из aris-skills.txt)
# ═══════════════════════════════════════

echo ">>> 7/13 ARIS skills..."
if [ -d "$STACK_DIR/aris-research-repo" ]; then
    bash "$STACK_DIR/sync-aris.sh" --update || echo "  ARIS: синхронизация пропущена"
else
    echo "  ARIS: клон не найден, пропускаю"
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
    if grep -q "^\[" "$NEW_ENV/Project.toml" 2>/dev/null; then
        echo "  Julia v$JULIA_VER окружение уже содержит пакеты"
    elif grep -q "^\[" "$OLD_ENV/Project.toml" 2>/dev/null; then
        echo "  Миграция пакетов: $(basename "$OLD_ENV") → $(basename "$NEW_ENV")"
        # Извлекаем имена пакетов из [deps] секции и создаём Julia-массив
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
            echo "  Переношу: $PACKAGES_JL"
            julia -e "using Pkg; Pkg.add($PACKAGES_JL)" 2>/dev/null || echo "  Миграция: пропущена (ошибка)"
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
wolframscript -code 'PacletInstall["Wolfram/AgentTools"]' 2>/dev/null || echo "  Wolfram: обновление пропущено (проверь лицензию)"
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
