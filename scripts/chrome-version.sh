#!/bin/bash
# Detect the Chrome version pinned by the installed tldraw-cli
# (via its bundled puppeteer). Prints the version or nothing.
# Usage:
#   VER=$(bash $STACK_DIR/scripts/chrome-version.sh)     # get version
#   bash $STACK_DIR/scripts/chrome-version.sh            # print

set -uo pipefail

STACK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TLDRAW_PUPPETEER="$(npm root -g 2>/dev/null)/@kitschpatrol/tldraw-cli/node_modules/puppeteer"

if [ ! -d "$TLDRAW_PUPPETEER" ]; then
    exit 1
fi

# executablePath() returns a path with the pinned version:
# ~/.cache/puppeteer/chrome/mac_arm-<version>/...
CHROME_PATH=$(node -e "require('$TLDRAW_PUPPETEER').executablePath().then(p => console.log(p)).catch(() => process.exit(1))" 2>/dev/null)

if [ -z "$CHROME_PATH" ]; then
    exit 1
fi

# Extract the X.Y.Z.W version from the path
VER=$(echo "$CHROME_PATH" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+' | head -1)

if [ -n "$VER" ]; then
    echo "$VER"
    exit 0
fi

exit 1
