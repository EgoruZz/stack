#!/bin/bash
# Управление маршрутизацией трафика стека через ISP-прокси (proxy.market).
#
# Принципы:
#   1. Локальный трафик стека (все 9 MCP, localhost, *.local) — НИКОГДА через
#      прокси. Гарантируется no_proxy в .zshrc.
#   2. git всегда через прокси (цель — github.com; push/pull не должны
#      зависеть от включённого VPN-клиента).
#   3. Прочий web-трафик терминала (brew, pip, npm, curl) — через общие
#      env-прокси из .zshrc; российские сервисы добавляй в no_proxy.
#
# Секреты НЕ хардкодятся: читаются из env (STACK_PROXY_*), которые задаёт
# .zshrc. Файл переносим и коммитобезопасен.
#
# Использование:
#   bash proxy.sh status   # текущее состояние (по умолчанию)
#   bash proxy.sh git on   # направить git через прокси
#   bash proxy.sh git off  # вернуть git на прямой маршрут
#   bash proxy.sh test     # проверить прокси живым запросом

set -uo pipefail

HOST="${STACK_PROXY_HOST:-212.68.182.64}"
HTTP_URL="${STACK_PROXY_HTTP:-}"

cmd="${1:-status}"

case "$cmd" in
status)
    echo "Прокси-хост: $HOST"
    echo "env http_proxy: ${http_proxy:-не задан}"
    echo "env no_proxy:   ${no_proxy:-не задан}"
    GIT_P=$(git config --global --get http.https://github.com.proxy 2>/dev/null)
    echo "git→github: ${GIT_P:-прямой маршрут}"
    ;;
git)
    case "${2:-on}" in
    on)
        [ -n "$HTTP_URL" ] || { echo "STACK_PROXY_HTTP не задан (проверь .zshrc)"; exit 1; }
        git config --global http.https://github.com.proxy "$HTTP_URL"
        echo "git → github.com через прокси ($HOST)"
        ;;
    off)
        git config --global --unset http.https://github.com.proxy 2>/dev/null
        echo "git → github.com прямой маршрут"
        ;;
    esac
    ;;
test)
    echo "Проверка прокси..."
    CODE=$(curl -s --max-time 20 -o /dev/null -w '%{http_code}' -x "${HTTP_URL}" https://api.github.com/zen)
    if [ "$CODE" = "200" ]; then
        echo "✅ прокси жив ($HOST), GitHub API отвечает"
        curl -s --max-time 20 -x "${HTTP_URL}" https://ipinfo.io/json 2>/dev/null | python3 -c "import json,sys; d=json.load(sys.stdin); print('   внешний IP через прокси:', d.get('ip'), d.get('city'), d.get('country'))" 2>/dev/null
    else
        echo "❌ прокси не отвечает (код $CODE)"
        exit 1
    fi
    ;;
*)
    echo "Использование: bash proxy.sh [status|git on|git off|test]"
    ;;
esac
