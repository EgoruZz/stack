#!/bin/bash
# Синхронизация stack-секции AGENTS.md во все проекты
# Заменяет ТОЛЬКО содержимое между STACK:START и STACK:END
# Проект-специфичное содержимое сохраняется
# Запуск: cd ~/stack && bash sync-agents.sh

set -uo pipefail

STACK_DIR="$HOME/stack"
STACK_AGENTS="$STACK_DIR/AGENTS.md"

if [ ! -f "$STACK_AGENTS" ]; then
    echo "ОШИБКА: $STACK_AGENTS не найден"
    exit 1
fi

if ! grep -q "STACK:START" "$STACK_AGENTS"; then
    echo "ОШИБКА: маркеры STACK:START/END не найдены в $STACK_AGENTS"
    exit 1
fi

echo "=== Синхронизация AGENTS.md ==="
echo ""

# Автопоиск проектов с AGENTS.md (кроме ~/stack/)
find_projects() {
    find "$HOME/projects" "$HOME/learn" "$HOME" -maxdepth 3 -name "AGENTS.md" \
        ! -path "$STACK_DIR/*" 2>/dev/null | while read -r f; do
        dirname "$f"
    done | sort -u
}

SYNCED=0
SKIPPED=0

for project in $(find_projects); do
    AGENTS="$project/AGENTS.md"

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
        echo "  $AGENTS: нет маркеров STACK:START/END — пропускаю"
        SKIPPED=$((SKIPPED + 1))
    fi
done

echo ""
echo "=== Готово! ==="
echo "  Синхронизировано: $SYNCED"
echo "  Пропущено: $SKIPPED"
echo ""
echo "ВАЖНО: Перезапусти OpenCode для применения изменений!"
echo "  Закрой все открытые сессии OpenCode и запусти заново."
