#!/bin/bash
# Синхронизация stack-секции AGENTS.md во все зарегистрированные проекты
# Читает реестр из ~/stack/projects.txt (по одному пути на строку)
# Заменяет ТОЛЬКО содержимое между STACK:START и STACK:END
# Проект-специфичное содержимое сохраняется
# Запуск: cd ~/stack && bash sync-agents.sh

set -uo pipefail

STACK_DIR="$HOME/stack"
STACK_AGENTS="$STACK_DIR/AGENTS.md"
REGISTRY="$STACK_DIR/projects.txt"

if [ ! -f "$STACK_AGENTS" ]; then
    echo "ОШИБКА: $STACK_AGENTS не найден"
    exit 1
fi

if ! grep -q "STACK:START" "$STACK_AGENTS"; then
    echo "ОШИБКА: маркеры STACK:START/END не найдены в $STACK_AGENTS"
    exit 1
fi

if [ ! -f "$REGISTRY" ]; then
    echo "ОШИБКА: реестр $REGISTRY не найден"
    echo "  Создай его: ~/stack/new-project.sh <путь>"
    exit 1
fi

echo "=== Синхронизация AGENTS.md ==="
echo ""

SYNCED=0
CREATED=0
SKIPPED=0
MISSING=0
SEEN=$(mktemp)

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

    AGENTS="$project/AGENTS.md"

    # Если AGENTS.md нет — копируем из стека
    if [ ! -f "$AGENTS" ]; then
        cp "$STACK_AGENTS" "$AGENTS"
        echo "  $AGENTS: создан из ~/stack/AGENTS.md"
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
echo "  Синхронизировано: $SYNCED"
echo "  Создано: $CREATED"
echo "  Пропущено (нет маркеров): $SKIPPED"
echo "  Не найдено (папка удалена): $MISSING"
echo ""
echo "ВАЖНО: Перезапусти OpenCode для применения изменений!"
echo "  Закрой все открытые сессии OpenCode и запусти заново."
