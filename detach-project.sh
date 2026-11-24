#!/bin/bash
# Отцепление стека от проекта (detach)
# Использование: bash detach-project.sh <путь-к-проекту>
#
# Делает:
#   1. Удаляет .opencode/ из проекта (агент больше не видит стек)
#   2. Убирает stack-секцию (между STACK:START/END) из AGENTS.md проекта
#   3. Убирает проект из реестра projects.txt
# Содержимое проекта (код, файлы) не трогается.

set -euo pipefail

STACK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REGISTRY="$STACK_DIR/projects.txt"

if [ $# -eq 0 ]; then
    echo "Использование: $0 <путь-к-проекту>"
    exit 1
fi

INPUT_DIR="$1"
case "$INPUT_DIR" in
    "~") INPUT_DIR="$HOME" ;;
    "~/"*) INPUT_DIR="$HOME/${INPUT_DIR#\~/}" ;;
esac

if [ ! -d "$INPUT_DIR" ]; then
    echo "❌ Папка не найдена: $INPUT_DIR"
    exit 1
fi
PROJECT_DIR=$(cd "$INPUT_DIR" && pwd)

if [ "$PROJECT_DIR" = "$STACK_DIR" ]; then
    echo "❌ Нельзя отцепить сам стек"
    exit 1
fi

echo "=== Отцепление стека: $PROJECT_DIR ==="

# 1. Конфиг OpenCode
if [ -d "$PROJECT_DIR/.opencode" ]; then
    rm -rf "$PROJECT_DIR/.opencode"
    echo "  ✅ .opencode/ удалён (MCP и скиллы больше не видны в этой папке)"
else
    echo "  ℹ️ .opencode/ не было"
fi

# 2. AGENTS.md: убираем stack-секцию, если есть
AGENTS="$PROJECT_DIR/AGENTS.md"
if [ -f "$AGENTS" ] && grep -q "STACK:START" "$AGENTS"; then
    python3 - "$AGENTS" << 'PYEOF'
import re, sys
p = sys.argv[1]
s = open(p).read()
s2 = re.sub(r'<!-- STACK:START -->.*?<!-- STACK:END -->\n?', '', s, flags=re.DOTALL)
open(p, 'w').write(s2)
print("  ✅ stack-секция убрана из AGENTS.md (остальное содержимое сохранено)")
PYEOF
else
    echo "  ℹ️ AGENTS.md без stack-секции"
fi

# 3. Реестр
if [ -f "$REGISTRY" ] && grep -qxF "$PROJECT_DIR" "$REGISTRY"; then
    grep -vxF "$PROJECT_DIR" "$REGISTRY" > "$REGISTRY.tmp" && mv "$REGISTRY.tmp" "$REGISTRY"
    echo "  ✅ Убран из projects.txt"
else
    echo "  ℹ️ В реестре не числился"
fi

echo ""
echo "✅ Готово: стек отцеплён от $PROJECT_DIR"
echo "   Вернуть: bash $STACK_DIR/new-project.sh $PROJECT_DIR"
