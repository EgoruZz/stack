#!/bin/bash
# gh CLI wrapper for the stack: proxy env + retries.
# Why: gh talks to api.github.com over HTTPS and must go through the stack proxy;
# the proxy occasionally drops connections, so retry twice before giving up.
# Usage: bash scripts/gh.sh <any gh args>   e.g. bash scripts/gh.sh pr view 31
STACK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

source "$STACK_DIR/scripts/proxy.sh" status >/dev/null 2>&1 || true
export http_proxy="$STACK_PROXY_HTTP" HTTP_PROXY="$STACK_PROXY_HTTP"
export https_proxy="$STACK_PROXY_HTTP" HTTPS_PROXY="$STACK_PROXY_HTTP"

attempt=0
while :; do
    if gh "$@"; then exit 0; fi
    attempt=$((attempt + 1))
    [ "$attempt" -ge 3 ] && exit 1
    echo "gh attempt $attempt failed — retrying via proxy..." >&2
    sleep 2
done
