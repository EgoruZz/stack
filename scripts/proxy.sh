#!/bin/bash
# ═══════════════════════════════════════════════════════════════
#  Stack networking: ISP proxy (proxy.market, Singapore)
# ═══════════════════════════════════════════════════════════════
# Dual mode:
#   • `source $STACK_DIR/scripts/proxy.sh` — from .zshrc: exports proxy env vars
#   • `bash $STACK_DIR/scripts/proxy.sh [command]` — management CLI
#
# Routing rules:
#   1. Local stack traffic (all MCP, localhost, *.local) — NEVER
#      through the proxy (no_proxy).
#   2. git → github.com — through the proxy (see `git on`).
#   3. Other terminal web traffic (brew, pip, npm, curl) — via env.
#      Add Russian services to no_proxy.
#
# Secrets live ONLY in ~/.stack-secrets.sh (outside the repo, chmod 600).
# This file contains only empty defaults and logic; no personal data.
# ═══════════════════════════════════════════════════════════════

STACK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PROXY_HOST_DEFAULT="212.68.182.64"
PROXY_USER_DEFAULT="cl0pmb4J"
PROXY_PASS_DEFAULT="7sU0M2hqyl"
PROXY_HTTP_PORT="50100"
PROXY_SOCKS_PORT="50101"
# Subscription expiry; check: bash proxy.sh expiry
PROXY_EXPIRES_DEFAULT="22.12.2026 13:30"
# ═══ Secrets — NOT in this file! ═══
# Personal values are set in ~/.stack-secrets.sh (file in $HOME,
# never committed to the repo):
#   PROXY_HOST="..."  PROXY_USER="..."  PROXY_PASS="..."
#   PROXY_EXPIRES="YYYY-MM-DD HH:MM +ZZZZ"
# The file is created by apply-first-start.sh from the form; template: first-start.template.txt.

# Personal config on top of defaults (secrets, not for the repo):
# ~/.stack-secrets.sh may override PROXY_HOST/USER/PASS/EXPIRES.
[ -f "$HOME/.stack-secrets.sh" ] && source "$HOME/.stack-secrets.sh"

PROXY_HOST="${PROXY_HOST:-$PROXY_HOST_DEFAULT}"
PROXY_USER="${PROXY_USER:-$PROXY_USER_DEFAULT}"
PROXY_PASS="${PROXY_PASS:-$PROXY_PASS_DEFAULT}"
PROXY_EXPIRES="${PROXY_EXPIRES:-$PROXY_EXPIRES_DEFAULT}"

# The form's PROXY_HOST may include the port ("host:port") — strip it:
# the ports are added below from PROXY_HTTP_PORT / PROXY_SOCKS_PORT.
PROXY_HOST="${PROXY_HOST%%:*}"
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
        echo "❌ STACK_PROXY_EXPIRES not recognized: '$STACK_PROXY_EXPIRES'"; return 1; }
    now=$(date +%s); diff=$(( (epoch - now) / 86400 ))
    if [ "$diff" -lt 0 ]; then
        echo "❌ Proxy expired! Renew the subscription: https://proxy.market (then update PROXY_* in proxy.sh or ~/.stack-secrets.sh)"
        return 1
    elif [ "$diff" -lt 7 ]; then
        echo "⚠️  Proxy expires in $diff days — renew: https://proxy.market"
    else
        echo "✅ Proxy valid ($diff days left), expires $STACK_PROXY_EXPIRES"
    fi
}

# ═══ CLI mode ═══
if [ "${BASH_SOURCE[0]}" = "$0" ]; then
    _stack_proxy_export_env
    case "${1:-status}" in
    status)
        if [ -n "$PROXY_HOST" ] && [ -n "$PROXY_USER" ]; then
            echo "Proxy host: $PROXY_HOST (http :$PROXY_HTTP_PORT, socks5 :$PROXY_SOCKS_PORT)"
        else
            echo "Proxy NOT configured (optional) — traffic goes direct."
            echo "To enable: fill in the proxy fields in $STACK_DIR/first-start.txt and run apply-first-start.sh"
            _stack_proxy_expiry 2>/dev/null || true
            return 0 2>/dev/null || exit 0
        fi
        _stack_proxy_expiry
        echo "env http_proxy set, no_proxy: $no_proxy"
        GIT_P=$(git config --global --get http.https://github.com.proxy 2>/dev/null)
        echo "git→github: ${GIT_P:+via proxy ($HOST)}${GIT_P:-direct route}"
        ;;
    expiry) _stack_proxy_expiry ;;
    git)
        case "${2:-on}" in
        on)
            git config --global http.https://github.com.proxy "$STACK_PROXY_HTTP"
            echo "git → github.com via proxy ($PROXY_HOST)" ;;
        off)
            git config --global --unset http.https://github.com.proxy 2>/dev/null
            echo "git → github.com direct route" ;;
        *) echo "Usage: bash proxy.sh git [on|off]" ;;
        esac ;;
    test)
        if [ -z "$PROXY_USER" ]; then
            echo "Proxy not configured (optional) — checking direct route..."
            CODE=$(curl -s --max-time 20 -o /dev/null -w '%{http_code}' https://api.github.com/zen)
            [ "$CODE" = "200" ] && echo "✅ direct GitHub access works" || echo "❌ direct access not working"
            exit 0
        fi
        echo "Checking proxy..."
        CODE=$(curl -s --max-time 20 -o /dev/null -w '%{http_code}' -x "$STACK_PROXY_HTTP" https://api.github.com/zen)
        if [ "$CODE" = "200" ]; then
            echo "✅ proxy alive ($PROXY_HOST), GitHub API responds"
            curl -s --max-time 20 -x "$STACK_PROXY_HTTP" https://ipinfo.io/json 2>/dev/null \
                | python3 -c "import json,sys; d=json.load(sys.stdin); print('   external IP:', d.get('ip'), d.get('city'), d.get('country'))" 2>/dev/null
            _stack_proxy_expiry
        else
            echo "❌ proxy not responding (code $CODE)"
            exit 1
        fi ;;
    *) echo "Usage: bash proxy.sh [status|expiry|git on|git off|test]" ;;
    esac
    exit 0
fi

# ═══ Source mode (from .zshrc) ═══
# The proxy is OPTIONAL: if personal values are not set (no
# ~/.stack-secrets.sh or empty fields) — traffic goes direct, the stack works.
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
