#!/bin/bash
# ═══════════════════════════════════════════════════════════════
#  Сеть стека: ISP-прокси (proxy.market, Singapore)
# ═══════════════════════════════════════════════════════════════
# Двойной режим:
#   • `source ~/stack/proxy.sh` — из .zshrc: экспортирует env-прокси
#   • `bash ~/stack/proxy.sh [команда]` — CLI управления
#
# Правила маршрутизации:
#   1. Локальный трафик стека (все MCP, localhost, *.local) — НИКОГДА
#      через прокси (no_proxy).
#   2. git → github.com — через прокси (см. `git on`).
#   3. Прочий web-трафик терминала (brew, pip, npm, curl) — через env.
#      Российские сервисы добавляй в no_proxy.
#
# Секреты живут ТОЛЬКО в ~/.stack-secrets.sh (вне репозитория, chmod 600).
# В этом файле — только пустые дефолты и логика; никаких персональных данных.
# ═══════════════════════════════════════════════════════════════

PROXY_HOST_DEFAULT=""
PROXY_USER_DEFAULT=""
PROXY_PASS_DEFAULT=""
PROXY_HTTP_PORT="50100"
PROXY_SOCKS_PORT="50101"
# Срок подписки; проверка: bash proxy.sh expiry
PROXY_EXPIRES_DEFAULT=""
# ═══ Секреты — НЕ в этом файле! ═══
# Персональные значения задаются в ~/.stack-secrets.sh (файл в $HOME,
# в репозиторий не попадает):
#   PROXY_HOST="..."  PROXY_USER="..."  PROXY_PASS="..."
#   PROXY_EXPIRES="2026-12-22 13:30 +0300"
# Файл создаётся apply-first-start.sh из формы; шаблон — first-start.template.txt.

# Личный конфиг поверх дефолтов (секреты, не для репозитория):
# ~/.stack-secrets.sh может переопределять PROXY_HOST/USER/PASS/EXPIRES.
[ -f "$HOME/.stack-secrets.sh" ] && source "$HOME/.stack-secrets.sh"

PROXY_HOST="${PROXY_HOST:-$PROXY_HOST_DEFAULT}"
PROXY_USER="${PROXY_USER:-$PROXY_USER_DEFAULT}"
PROXY_PASS="${PROXY_PASS:-$PROXY_PASS_DEFAULT}"
PROXY_EXPIRES="${PROXY_EXPIRES:-$PROXY_EXPIRES_DEFAULT}"

STACK_PROXY_HOST="$PROXY_HOST"
STACK_PROXY_HTTP="http://$PROXY_USER:$PROXY_PASS@$PROXY_HOST:$PROXY_HTTP_PORT"
STACK_PROXY_SOCKS="socks5://$PROXY_USER:$PROXY_PASS@$PROXY_HOST:$PROXY_SOCKS_PORT"
STACK_PROXY_EXPIRES="$PROXY_EXPIRES"

_stack_proxy_export_env() {
    export STACK_PROXY_HOST STACK_PROXY_HTTP STACK_PROXY_SOCKS STACK_PROXY_EXPIRES
    export http_proxy="$STACK_PROXY_HTTP" HTTP_PROXY="$STACK_PROXY_HTTP"
    export https_proxy="$STACK_PROXY_HTTP" HTTPS_PROXY="$STACK_PROXY_HTTP"
    export all_proxy="$STACK_PROXY_SOCKS"
    export no_proxy="localhost,127.0.0.1,::1,*.local"
    export NO_PROXY="$no_proxy"
}

_stack_proxy_expiry() {
    local epoch now diff
    epoch=$(date -j -f "%Y-%m-%d %H:%M %z" "$STACK_PROXY_EXPIRES" +%s 2>/dev/null) || {
        echo "❌ STACK_PROXY_EXPIRES не распознан: '$STACK_PROXY_EXPIRES'"; return 1; }
    now=$(date +%s); diff=$(( (epoch - now) / 86400 ))
    if [ "$diff" -lt 0 ]; then
        echo "❌ Прокси истёк! Продли подписку: https://proxy.market (затем обнови PROXY_* в proxy.sh или ~/.stack-secrets.sh)"
        return 1
    elif [ "$diff" -lt 7 ]; then
        echo "⚠️  Прокси истекает через $diff дн. — продлевай: https://proxy.market"
    else
        echo "✅ Прокси действителен (осталось $diff дней), истекает $STACK_PROXY_EXPIRES"
    fi
}

# ═══ CLI-режим ═══
if [ "${BASH_SOURCE[0]}" = "$0" ]; then
    _stack_proxy_export_env
    case "${1:-status}" in
    status)
        if [ -n "$PROXY_HOST" ] && [ -n "$PROXY_USER" ]; then
            echo "Прокси-хост: $PROXY_HOST (http :$PROXY_HTTP_PORT, socks5 :$PROXY_SOCKS_PORT)"
        else
            echo "Прокси НЕ настроен (опционально) — трафик идёт напрямую."
            echo "Чтобы включить: заполни поля прокси в ~/stack/first-start.txt и запусти apply-first-start.sh"
            _stack_proxy_expiry 2>/dev/null || true
            return 0 2>/dev/null || exit 0
        fi
        _stack_proxy_expiry
        echo "env http_proxy задан, no_proxy: $no_proxy"
        GIT_P=$(git config --global --get http.https://github.com.proxy 2>/dev/null)
        echo "git→github: ${GIT_P:+через прокси ($HOST)}${GIT_P:-прямой маршрут}"
        ;;
    expiry) _stack_proxy_expiry ;;
    git)
        case "${2:-on}" in
        on)
            git config --global http.https://github.com.proxy "$STACK_PROXY_HTTP"
            echo "git → github.com через прокси ($PROXY_HOST)" ;;
        off)
            git config --global --unset http.https://github.com.proxy 2>/dev/null
            echo "git → github.com прямой маршрут" ;;
        *) echo "Использование: bash proxy.sh git [on|off]" ;;
        esac ;;
    test)
        if [ -z "$PROXY_USER" ]; then
            echo "Прокси не настроен (опционально) — проверяю прямой маршрут..."
            CODE=$(curl -s --max-time 20 -o /dev/null -w '%{http_code}' https://api.github.com/zen)
            [ "$CODE" = "200" ] && echo "✅ прямой доступ к GitHub работает" || echo "❌ прямой доступ не работает"
            exit 0
        fi
        echo "Проверка прокси..."
        CODE=$(curl -s --max-time 20 -o /dev/null -w '%{http_code}' -x "$STACK_PROXY_HTTP" https://api.github.com/zen)
        if [ "$CODE" = "200" ]; then
            echo "✅ прокси жив ($PROXY_HOST), GitHub API отвечает"
            curl -s --max-time 20 -x "$STACK_PROXY_HTTP" https://ipinfo.io/json 2>/dev/null \
                | python3 -c "import json,sys; d=json.load(sys.stdin); print('   внешний IP:', d.get('ip'), d.get('city'), d.get('country'))" 2>/dev/null
            _stack_proxy_expiry
        else
            echo "❌ прокси не отвечает (код $CODE)"
            exit 1
        fi ;;
    *) echo "Использование: bash proxy.sh [status|expiry|git on|git off|test]" ;;
    esac
    exit 0
fi

# ═══ Режим source (из .zshrc) ═══
# Прокси ОПЦИОНАЛЕН: если персональные значения не заданы (нет
# ~/.stack-secrets.sh или поля пустые) — трафик идёт напрямую, стек работает.
_stack_proxy_export_env() {
    export STACK_PROXY_HOST STACK_PROXY_HTTP STACK_PROXY_SOCKS STACK_PROXY_EXPIRES
    if [ -n "$PROXY_HOST" ] && [ -n "$PROXY_USER" ] && [ -n "$PROXY_PASS" ]; then
        export http_proxy="$STACK_PROXY_HTTP" HTTP_PROXY="$STACK_PROXY_HTTP"
        export https_proxy="$STACK_PROXY_HTTP" HTTPS_PROXY="$STACK_PROXY_HTTP"
        export all_proxy="$STACK_PROXY_SOCKS"
        export no_proxy="localhost,127.0.0.1,::1,*.local"
        export NO_PROXY="$no_proxy"
    else
        unset http_proxy HTTP_PROXY https_proxy HTTPS_PROXY all_proxy 2>/dev/null
        export no_proxy="localhost,127.0.0.1,::1,*.local"
        export NO_PROXY="$no_proxy"
    fi
}
_stack_proxy_export_env
