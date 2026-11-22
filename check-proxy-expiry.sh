#!/bin/bash
# Проверка срока действия ISP-прокси (proxy.market)
# Запуск: cd ~/stack && bash check-proxy-expiry.sh
# Дата задаётся в .zshrc: export STACK_PROXY_EXPIRES="YYYY-MM-DD HH:MM +HHMM"

EXPIRES="${STACK_PROXY_EXPIRES:-}"

if [ -z "$EXPIRES" ]; then
    echo "❌ STACK_PROXY_EXPIRES не задан (проверь .zshrc)"
    exit 1
fi

EXPIRY_EPOCH=$(date -j -f "%Y-%m-%d %H:%M %z" "$EXPIRES" +%s 2>/dev/null)
if [ -z "$EXPIRY_EPOCH" ]; then
    echo "❌ Не удалось распознать дату: '$EXPIRES' (формат: 2026-12-22 13:30 +0300)"
    exit 1
fi

NOW=$(date +%s)
DIFF=$(( ($EXPIRY_EPOCH - $NOW) / 86400 ))

echo "Прокси: $STACK_PROXY_HOST (proxy.market), истекает $EXPIRES"
if [ "$DIFF" -lt 0 ]; then
    echo "❌ Прокси истёк! Обнови подписку: https://proxy.market"
    echo "   После продления обнови IP/логин/пароль в .zshrc (STACK_PROXY_*)"
    exit 1
elif [ "$DIFF" -lt 7 ]; then
    echo "⚠️  До истечения прокси осталось менее 7 дней ($DIFF дн.)!"
    echo "   Продли: https://proxy.market"
elif [ "$DIFF" -lt 14 ]; then
    echo "⚠️  До истечения прокси $DIFF дней — пора продлевать"
else
    echo "✅ Прокси действителен (осталось $DIFF дней)"
fi
