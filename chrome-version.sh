#!/bin/bash
# Определяет версию Chrome, закреплённую установленным tldraw-cli
# (через его bundled puppeteer). Печатает версию или ничего.
# Использование:
#   VER=$(bash ~/stack/chrome-version.sh)     # получить версию
#   bash ~/stack/chrome-version.sh            # напечатать

set -uo pipefail

TLDRAW_PUPPETEER="$(npm root -g 2>/dev/null)/@kitschpatrol/tldraw-cli/node_modules/puppeteer"

if [ ! -d "$TLDRAW_PUPPETEER" ]; then
    exit 1
fi

# executablePath() отдаёт путь с закреплённой версией:
# ~/.cache/puppeteer/chrome/mac_arm-<version>/...
CHROME_PATH=$(node -e "require('$TLDRAW_PUPPETEER').executablePath().then(p => console.log(p)).catch(() => process.exit(1))" 2>/dev/null)

if [ -z "$CHROME_PATH" ]; then
    exit 1
fi

# Извлекаем версию X.Y.Z.W из пути
VER=$(echo "$CHROME_PATH" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+' | head -1)

if [ -n "$VER" ]; then
    echo "$VER"
    exit 0
fi

exit 1
