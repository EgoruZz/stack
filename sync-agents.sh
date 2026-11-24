#!/bin/bash
# Синхронизация stack-секции AGENTS.md во все зарегистрированные проекты
# Читает реестр из $STACK_DIR/projects.txt (по одному пути на строку)
# Заменяет ТОЛЬКО содержимое между STACK:START и STACK:END
# Проект-специфичное содержимое сохраняется
# Использование:
#   bash sync-agents.sh              # синхронизация + подсказка о перезапуске
#   bash sync-agents.sh --no-hint    # без подсказки (для вызова из update-all.sh)
#   bash sync-agents.sh --discover   # + автоиндексирование: найти проекты по
#                                    #   маркеру .opencode/opencode.json и
#                                    #   добавить их в реестр

set -uo pipefail

STACK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STACK_TEMPLATE="$STACK_DIR/AGENTS.template.md"
REGISTRY="$STACK_DIR/projects.txt"

if [ ! -f "$STACK_TEMPLATE" ]; then
    echo "ОШИБКА: $STACK_TEMPLATE не найден"
    exit 1
fi

if ! grep -q "STACK:START" "$STACK_TEMPLATE"; then
    echo "ОШИБКА: маркеры STACK:START/END не найдены в $STACK_TEMPLATE"
    exit 1
fi

# Подстановка реального пути стека: AGENTS.template.md хранит {{STACK}} —
# при синхронизации каждый проект (и сам стек) получает фактический путь.
STACK_AGENTS="$(mktemp)"
trap 'rm -f "$STACK_AGENTS"' EXIT
sed "s|{{STACK}}|$STACK_DIR|g" "$STACK_TEMPLATE" > "$STACK_AGENTS"

# Рендер AGENTS.md для сессий в самом стеке (gitignored, локальный)
sed "s|{{STACK}}|$STACK_DIR|g" "$STACK_TEMPLATE" > "$STACK_DIR/AGENTS.md"

if ! grep -q "STACK:START" "$STACK_AGENTS"; then
    echo "ОШИБКА: маркеры STACK:START/END не найдены в $STACK_AGENTS"
    exit 1
fi

if [ ! -f "$REGISTRY" ]; then
    if [ -f "$STACK_DIR/projects.template.txt" ]; then
        cp "$STACK_DIR/projects.template.txt" "$REGISTRY"
        echo "  projects.txt создан из шаблона (пустой — добавь проекты: $STACK_DIR/new-project.sh <путь>)"
    else
        echo "ОШИБКА: реестр $REGISTRY не найден и шаблона нет"
        echo "  Создай его: $STACK_DIR/new-project.sh <путь>"
        exit 1
    fi
fi

echo "=== Синхронизация AGENTS.md и конфигов OpenCode ==="
echo ""

# --discover: автоиндексирование — ищем проекты по маркеру
# .opencode/opencode.json (его создаёт new-project.sh) и добавляем
# найденное в реестр. Сам стек исключается.
if [ "${1:-}" = "--discover" ] || [ "${2:-}" = "--discover" ]; then
    echo "── Автоиндексирование проектов (маркер: .opencode/opencode.json)..."
    FOUND=$(find "$HOME" -maxdepth 4 -type d -name .opencode -not -path "*/node_modules/*" -not -path "$STACK_DIR/*" -not -path "*/Library/*" -not -path "*/.Trash/*" 2>/dev/null | sed 's|/.opencode$||' | sort -u)
    ADDED=0
    while IFS= read -r d; do
        [ -z "$d" ] && continue
        [ -f "$d/.opencode/opencode.json" ] || continue
        if ! grep -qxF "$d" "$REGISTRY" 2>/dev/null; then
            echo "$d" >> "$REGISTRY"
            echo "  + найден и добавлен: $d"
            ADDED=$((ADDED + 1))
        fi
    done <<EOF
$FOUND
EOF
    echo "  добавлено новых: $ADDED"
    echo ""
fi

SYNCED=0
CREATED=0
CONFIGURED=0
MISSING=0
SEEN=$(mktemp)

# Конфиг самого стека (для сессий в $STACK_DIR) — перегенерируем из шаблона
bash "$STACK_DIR/gen-opencode-config.sh" "$STACK_DIR" >/dev/null 2>&1 \
    && echo "  $STACK_DIR/.opencode/opencode.json: перегенерирован" \
    || echo "  ⚠️ конфиг $STACK_DIR не сгенерирован"

while IFS= read -r project || [ -n "$project" ]; do
    # Пропускаем комментарии и пустые строки
    [[ "$project" =~ ^[[:space:]]*# ]] && continue
    [[ -z "${project// }" ]] && continue

    # Разворачиваем ~ в абсолютный путь (без eval)
    case "$project" in
        "~") project="$HOME" ;;
        "~/"*) project="$HOME/${project#\~/}" ;;
    esac

    # Дедупликация
    if grep -qxF "$project" "$SEEN" 2>/dev/null; then
        continue
    fi
    echo "$project" >> "$SEEN"

    if [ ! -d "$project" ]; then
        echo "  $project: папка не найдена — пропускаю"
        MISSING=$((MISSING + 1))
        continue
    fi

    # Конфиг OpenCode (.opencode/opencode.json) — MCP/skills стека для проекта.
    # Стек поднимается только там, где сгенерирован этот файл.
    if bash "$STACK_DIR/gen-opencode-config.sh" "$project" >/dev/null 2>&1; then
        CONFIGURED=$((CONFIGURED + 1))
    else
        echo "  $project: ⚠️ конфиг OpenCode не сгенерирован"
    fi

    AGENTS="$project/AGENTS.md"

    # Если AGENTS.md нет — копируем из стека
    if [ ! -f "$AGENTS" ]; then
        cp "$STACK_AGENTS" "$AGENTS"
        echo "  $AGENTS: создан из $STACK_DIR/AGENTS.md"
        CREATED=$((CREATED + 1))
        continue
    fi

    if grep -q "STACK:START" "$AGENTS" 2>/dev/null; then
        # Есть маркеры — заменяем между ними
        python3 - "$AGENTS" "$STACK_AGENTS" << 'PYEOF'
import re, sys

agents_path, stack_path = sys.argv[1], sys.argv[2]

with open(stack_path) as f:
    stack = f.read()
with open(agents_path) as f:
    content = f.read()

match = re.search(r'<!-- STACK:START -->.*?<!-- STACK:END -->', stack, re.DOTALL)
if not match:
    print(f'  {agents_path}: STACK:START/END не найдены в источнике')
    sys.exit(1)

stack_section = match.group()
content = re.sub(
    r'<!-- STACK:START -->.*?<!-- STACK:END -->',
    stack_section, content, flags=re.DOTALL
)
with open(agents_path, 'w') as f:
    f.write(content)
print(f'  {agents_path}: синхронизирован')
PYEOF
        SYNCED=$((SYNCED + 1))
    else
        # Нет маркеров — добавляем stack-секцию после заголовка (# AGENTS.md)
        python3 - "$AGENTS" "$STACK_AGENTS" << 'PYEOF'
import re, sys

agents_path, stack_path = sys.argv[1], sys.argv[2]

with open(stack_path) as f:
    stack = f.read()
with open(agents_path) as f:
    content = f.read()

stack_match = re.search(r'<!-- STACK:START -->.*?<!-- STACK:END -->', stack, re.DOTALL)
if not stack_match:
    print(f'  {agents_path}: STACK:START/END не найдены в источнике')
    sys.exit(1)

stack_section = stack_match.group()

# Находим конец заголовка (строка # AGENTS.md) и вставляем stack-секцию после неё
lines = content.split('\n')
insert_idx = 0
for i, line in enumerate(lines):
    if line.startswith('# '):
        insert_idx = i + 1
        break
# Пропускаем пустые строки после заголовка
while insert_idx < len(lines) and not lines[insert_idx].strip():
    insert_idx += 1

new_lines = lines[:insert_idx] + stack_section.split('\n') + [''] + lines[insert_idx:]
with open(agents_path, 'w') as f:
    f.write('\n'.join(new_lines))
print(f'  {agents_path}: маркеры добавлены, синхронизирован')
PYEOF
        SYNCED=$((SYNCED + 1))
    fi
done < "$REGISTRY"

rm -f "$SEEN"

echo ""
echo "=== Готово! ==="
echo "  Синхронизировано AGENTS.md: $SYNCED"
echo "  Создано AGENTS.md: $CREATED"
echo "  Сгенерировано конфигов OpenCode: $CONFIGURED"
echo "  Не найдено (папка удалена): $MISSING"

# Подсказка о перезапуске (скрывается флагом --no-hint для update-all.sh)
if [ "${1:-}" != "--no-hint" ]; then
    echo ""
    echo "ВАЖНО: Перезапусти OpenCode для применения изменений!"
    echo "  Закрой все открытые сессии OpenCode и запусти заново."
fi
