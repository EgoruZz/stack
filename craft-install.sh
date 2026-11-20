#!/bin/bash
# Установка/обновление GUI-приложений Craft Apps (ArtCraft) в /Applications
# Заменяет ArtCraft Launcher: сам находит свежие версии на GitHub и
# обновляет только те приложения, чья версия изменилась.
#
# Запуск в ТЕРМИНАЛЕ пользователя (не из OpenCode — его песочница
# блокирует hdiutil). Путь: ~/stack/craft-install.sh. DMG кэшируются в
# ~/stack/craft-downloads/ (gitignored).
# блокирует hdiutil):
#   bash ~/stack/craft-downloads/install-craft-apps.sh [--force]
set -uo pipefail

DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$DIR"
FORCE=${1:-}

APPS="wordcraft gridcraft deckcraft pdfcraft"

# Последняя версия приложения из GitHub API (тег vX.Y.Z -> X.Y.Z)
latest_ver() {
    curl -sL --max-time 30 "https://api.github.com/repos/storytold/$1/releases/latest" \
        | grep -o '"tag_name": "[^"]*"' | cut -d'"' -f4 | sed 's/^v//'
}

installed_ver() {
    # имя приложения в /Applications: wordcraft -> WordCraft и т.п.
    local app
    case "$1" in
        wordcraft) app=WordCraft ;;
        gridcraft) app=GridCraft ;;
        deckcraft) app=DeckCraft ;;
        pdfcraft)  app=PdfCraft ;;
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
        echo "   ❌ не смонтировался"
        return 1
    fi
    app=$(ls -d "$mnt"/*.app 2>/dev/null | head -1)
    if [ -n "$app" ]; then
        rm -rf "/Applications/$(basename "$app")"
        cp -R "$app" /Applications/ && echo "   ✅ $(basename "$app") → /Applications/"
    else
        echo "   ❌ .app не найден в $mnt"
    fi
    hdiutil detach "$mnt" -quiet 2>/dev/null
}

for name in $APPS; do
    VER=$(latest_ver "$name")
    if [ -z "$VER" ]; then
        echo "── $name: не удалось получить версию с GitHub — пропускаю"
        continue
    fi
    CUR=$(installed_ver "$name")
    DMG="$name-$VER-macos-universal.dmg"
    if [ "$CUR" = "$VER" ] && [ "$FORCE" != "--force" ]; then
        echo "── $name: v$VER установлена, актуально"
        continue
    fi
    if [ -n "$CUR" ]; then
        echo "── $name: обновление v$CUR → v$VER"
    else
        echo "── $name: установка v$VER"
    fi
    if [ ! -f "$DMG" ]; then
        curl -sL --max-time 600 -O \
            "https://github.com/storytold/$name/releases/download/v$VER/$DMG" \
            || { echo "   ❌ скачивание не удалось"; continue; }
    fi
    install_dmg "$DMG"
done

echo ""
echo "Проверка:"
for pair in "WordCraft wordcraft" "GridCraft gridcraft" "DeckCraft deckcraft" "PdfCraft pdfcraft"; do
    set -- $pair
    V=$(installed_ver "$2")
    [ -n "$V" ] && echo "  ✅ $1 v$V" || echo "  ❌ $1 не установлен"
done
echo ""
echo "CLI (headless, для MCP): ~/stack/craft-cli/ — обновляются setup.sh,"
echo "проверяются check-all.sh и update-all.sh."
echo "После установки/обновления: перезапусти OpenCode."
