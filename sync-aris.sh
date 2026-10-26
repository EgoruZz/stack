#!/bin/bash
# Синхронизация ARIS-скиллов из клона в ~/.config/opencode/skills/
# Список скиллов: ~/stack/aris-skills.txt (единый источник правды)
# Использование:
#   bash sync-aris.sh            # только синхронизация
#   bash sync-aris.sh --update   # git pull клона + синхронизация

set -uo pipefail

STACK_DIR="$HOME/stack"
SKILLS_DIR="$HOME/.config/opencode/skills"
ARIS_REPO="$STACK_DIR/aris-research-repo"
ARIS_LIST="$STACK_DIR/aris-skills.txt"

if [ ! -f "$ARIS_LIST" ]; then
    echo "ОШИБКА: $ARIS_LIST не найден"
    exit 1
fi

if [ ! -d "$ARIS_REPO/skills" ]; then
    echo "ОШИБКА: $ARIS_REPO/skills не найден (клон не установлен)"
    echo "  Запусти: bash $STACK_DIR/setup.sh"
    exit 1
fi

# --update: сначала обновляем клон
if [ "${1:-}" = "--update" ]; then
    (cd "$ARIS_REPO" && git pull --ff-only 2>/dev/null && echo "  ARIS репо обновлён" || echo "  ARIS репо: актуален или ошибка")
fi

mkdir -p "$SKILLS_DIR"

SYNCED=0
MISSING=0

while IFS= read -r skill || [ -n "$skill" ]; do
    # Пропускаем комментарии и пустые строки
    [[ "$skill" =~ ^[[:space:]]*# ]] && continue
    [[ -z "${skill// }" ]] && continue

    skill="${skill// /}"

    if [ -d "$ARIS_REPO/skills/$skill" ]; then
        rsync -a --delete "$ARIS_REPO/skills/$skill/" "$SKILLS_DIR/$skill/" 2>/dev/null
        SYNCED=$((SYNCED + 1))
    else
        echo "  $skill: не найден в ARIS репо — пропускаю"
        MISSING=$((MISSING + 1))
    fi
done < "$ARIS_LIST"

echo "  ARIS skills синхронизированы: $SYNCED"
[ "$MISSING" -gt 0 ] && echo "  Не найдено в репо: $MISSING (проверь aris-skills.txt)"
exit 0
