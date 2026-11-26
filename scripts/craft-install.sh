#!/bin/bash
# Install/update GUI Craft Apps (ArtCraft) applications in /Applications
# Replaces ArtCraft Launcher: finds fresh versions on GitHub itself and
# updates only the apps whose version changed.
#
# Run in the USER'S TERMINAL (not from OpenCode — its sandbox
# blocks hdiutil). Path: $STACK_DIR/scripts/craft-install.sh. DMGs are cached in
# $STACK_DIR/craft-downloads/ (gitignored).
# blocks hdiutil):
#   bash $STACK_DIR/craft-downloads/install-craft-apps.sh [--force]
set -uo pipefail

STACK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$DIR"
FORCE=${1:-}

APPS="wordcraft gridcraft deckcraft pdfcraft figcraft"

# Latest app version from the GitHub API (tag vX.Y.Z -> X.Y.Z)
latest_ver() {
    curl -sL --max-time 30 "https://api.github.com/repos/storytold/$1/releases/latest" \
        | grep -o '"tag_name": "[^"]*"' | cut -d'"' -f4 | sed 's/^v//'
}

installed_ver() {
    # app name in /Applications: wordcraft -> WordCraft etc.
    local app
    case "$1" in
        wordcraft) app=WordCraft ;;
        gridcraft) app=GridCraft ;;
        deckcraft) app=DeckCraft ;;
        pdfcraft)  app=PdfCraft ;;
        figcraft)  app=FigCraft ;;
    esac
    [ -d "/Applications/$app.app" ] \
        && defaults read "/Applications/$app.app/Contents/Info.plist" CFBundleShortVersionString 2>/dev/null \
        || echo ""
}

install_dmg() {
    local file=$1
    echo "── $file ..."
    local mnt app
    mnt=$(hdiutil attach -nobrowse "$file" 2>/dev/null \
        | grep '/Volumes/' | sed 's/.*\(\/Volumes\/.*\)$/\1/' | tail -1)
    if [ -z "$mnt" ]; then
        echo "   ❌ failed to mount"
        return 1
    fi
    app=$(ls -d "$mnt"/*.app 2>/dev/null | head -1)
    if [ -n "$app" ]; then
        rm -rf "/Applications/$(basename "$app")"
        cp -R "$app" /Applications/ && echo "   ✅ $(basename "$app") → /Applications/"
    else
        echo "   ❌ .app not found in $mnt"
    fi
    hdiutil detach "$mnt" -quiet 2>/dev/null
}

for name in $APPS; do
    VER=$(latest_ver "$name")
    if [ -z "$VER" ]; then
        echo "── $name: could not get version from GitHub — skipping"
        continue
    fi
    CUR=$(installed_ver "$name")
    DMG="$name-$VER-macos-universal.dmg"
    if [ "$CUR" = "$VER" ] && [ "$FORCE" != "--force" ]; then
        echo "── $name: v$VER installed, up to date"
        continue
    fi
    if [ -n "$CUR" ]; then
        echo "── $name: updating v$CUR → v$VER"
    else
        echo "── $name: installing v$VER"
    fi
    if [ ! -f "$DIR/$DMG" ]; then
        curl -sL --max-time 600 -o "$DIR/$DMG" \
            "https://github.com/storytold/$name/releases/download/v$VER/$DMG" \
            || { echo "   ❌ download failed"; continue; }
    fi
    install_dmg "$DMG"
done

echo ""
echo "Verification:"
for pair in "WordCraft wordcraft" "GridCraft gridcraft" "DeckCraft deckcraft" "PdfCraft pdfcraft" "FigCraft figcraft"; do
    set -- $pair
    V=$(installed_ver "$2")
    [ -n "$V" ] && echo "  ✅ $1 v$V" || echo "  ❌ $1 not installed"
done
echo ""
echo "CLI (headless, for MCP): $STACK_DIR/craft-cli/ — updated by setup.sh,"
echo "checked by check-all.sh and update-all.sh."
echo "After installing/updating: restart OpenCode."
