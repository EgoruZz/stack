#!/bin/bash
# Сбор личных (в git не попадающих) данных стека в одну папку —
# для бэкапа или переезда на другую машину.
#
# Использование:
#   bash export-personal.sh [целевая-папка]
#   # по умолчанию: ~/stack-personal-backup-YYYY-MM-DD/
#
# Собирает (если существуют):
#   projects.txt      — реестр проектов
#   first-start.txt   — заполненная форма первого старта
#   ~/.stack-secrets.sh — персональные данные (прокси, Wolfram ID, git identity)
#   ~/skills/         — хелпер tldraw-offline (ставится приложением tldraw)

set -euo pipefail

STACK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEST="${1:-$HOME/stack-personal-backup-$(date +%F)}"

if [ -e "$DEST" ] && [ -n "$(ls -A "$DEST" 2>/dev/null)" ]; then
    echo "❌ Целевая папка не пуста: $DEST — укажи другую"
    exit 1
fi
mkdir -p "$DEST"

COPIED=0
copy() {
    if [ -e "$1" ]; then
        cp -R "$1" "$DEST/" && echo "  ✅ $1" && COPIED=$((COPIED + 1))
    else
        echo "  ℹ️ нет: $1"
    fi
}

echo "=== Сбор личных данных стека → $DEST ==="
copy "$STACK_DIR/projects.txt"
copy "$STACK_DIR/first-start.txt"
copy "$HOME/.stack-secrets.sh"
copy "$HOME/skills"

echo ""
echo "✅ Готово ($COPIED шт.): $DEST"
echo ""
echo "Восстановление на другой машине (после setup.sh):"
echo "  cp <папка>/projects.txt <папка>/first-start.txt \$STACK_DIR/"
echo "  cp <папка>/.stack-secrets.sh ~/"
echo "  cp -R <папка>/skills ~/   # если был tldraw-offline"
echo "  bash \$STACK_DIR/apply-first-start.sh"
echo "  bash \$STACK_DIR/sync-agents.sh"
