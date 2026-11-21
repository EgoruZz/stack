#!/bin/bash
# Генерирует .opencode/opencode.json — конфиг стека (MCP + skills)
# для указанной директории (по умолчанию ~/stack).
#
# Стек работает ТОЛЬКО в проектах, где сгенерирован этот файл.
# Глобальный ~/.config/opencode стек не использует.
#
# Пути записываются через {env:HOME} — OpenCode подставляет переменные
# окружения при чтении конфига, поэтому файл переносим между машинами.
#
# Использование:
#   bash gen-opencode-config.sh                # для ~/stack
#   bash gen-opencode-config.sh ~/projects/foo # для проекта

set -euo pipefail

TARGET="${1:-$HOME/stack}"

mkdir -p "$TARGET/.opencode"

# ── Wolfram: бинарник вычисляется на этой машине (путь не переносим, но конфиг
# всегда перегенерируется через gen-opencode-config.sh / sync-agents.sh).
# Кандидаты: Wolfram Engine, Wolfram Desktop, Wolfram Research (alpha-нумерация).
WOLFRAM_BIN=""
for cand in \
    "/Applications/Wolfram Engine.app/Contents/Resources/Wolfram Player.app/Contents/MacOS/wolfram" \
    /Applications/Wolfram*.app/Contents/Resources/Wolfram\ Player.app/Contents/MacOS/wolfram \
    /Applications/Wolfram*.app/SystemFiles/FrontEnd/Executables/MacOSX/WolframKernel; do
    if [ -x "$cand" ]; then
        WOLFRAM_BIN="$cand"
        break
    fi
done
# Fallback: wolframscript рядом обычно лежит и ядро
if [ -z "$WOLFRAM_BIN" ] && command -v wolframscript &>/dev/null; then
    WS_DIR="$(cd "$(dirname "$(command -v wolframscript)")/.." && pwd)"
    KERN=$(find "$WS_DIR" -name wolfram -type f -perm +111 2>/dev/null | head -1)
    [ -n "$KERN" ] && WOLFRAM_BIN="$KERN"
fi
if [ -z "$WOLFRAM_BIN" ]; then
    echo "  ⚠️ Wolfram ядро не найдено — оставляю дефолтный путь (проверь вручную)"
    WOLFRAM_BIN="/Applications/Wolfram Engine.app/Contents/Resources/Wolfram Player.app/Contents/MacOS/wolfram"
fi

# WOLFRAM_BASE = Resources-каталог корневого .app (замена несуществующего /Library/WolframEngine).
# Структура: Wolfram Engine.app/Contents/Resources/Wolfram Player.app/Contents/MacOS/wolfram
WOLFRAM_BASE=""
DIR="$(dirname "$WOLFRAM_BIN")"
while [ "$DIR" != "/" ]; do
    if [ "$(basename "$DIR")" = "Contents" ]; then
        CAND="$(dirname "$(dirname "$DIR")")/Contents/Resources"
        [ -d "$CAND" ] && WOLFRAM_BASE="$CAND" && break
    fi
    DIR="$(dirname "$DIR")"
done
[ -n "$WOLFRAM_BASE" ] || WOLFRAM_BASE="/Applications/Wolfram Engine.app/Contents/Resources"

cat > "$TARGET/.opencode/opencode.json" << 'CONF'
{
  "__SCHEMA__": "https://opencode.ai/config.json",
  "skills": ["{env:HOME}/stack/skills-store"],
  "mcp": {
    "Wolfram": {
      "type": "local",
      "command": [
        "__WOLFRAM_BIN__",
        "-run",
        "PacletSymbol[\"Wolfram/AgentTools\",\"Wolfram`AgentTools`StartMCPServer\"][]",
        "-noinit",
        "-noprompt"
      ],
      "enabled": true,
      "environment": {
        "MCP_SERVER_NAME": "WolframLanguage",
        "WOLFRAM_BASE": "__WOLFRAM_BASE__",
        "WOLFRAM_LOCALBASE": "{env:HOME}/Library/Wolfram/Objects",
        "WOLFRAM_USERBASE": "{env:HOME}/Library/WolframEngine"
      },
      "timeout": 120000
    },
    "julia": {
      "type": "local",
      "command": ["{env:HOME}/stack/julia-mcp-env/bin/python", "{env:HOME}/stack/julia-mcp/server.py"],
      "enabled": true,
      "timeout": 60000
    },
    "manim": {
      "type": "local",
      "command": ["{env:HOME}/stack/manim-env/bin/python", "{env:HOME}/stack/manim-mcp/src/manim_server.py"],
      "enabled": true,
      "timeout": 120000
    },
    "ParaView": {
      "type": "local",
      "command": ["{env:HOME}/stack/paraview-mcp-env/bin/python", "{env:HOME}/stack/paraview-mcp/paraview_mcp_server.py"],
      "enabled": true,
      "timeout": 60000
    },
    "tldraw": {
      "type": "local",
      "command": ["node", "{env:HOME}/stack/tldraw-mcp/dist/index.js"],
      "enabled": true,
      "timeout": 60000
    },
    "wordcraft": {
      "type": "local",
      "command": ["{env:HOME}/stack/craft-cli/wordcraft-cli", "mcp"],
      "enabled": true,
      "timeout": 120000
    },
    "gridcraft": {
      "type": "local",
      "command": ["{env:HOME}/stack/craft-cli/gridcraft-cli", "mcp"],
      "enabled": true,
      "timeout": 120000
    },
    "deckcraft": {
      "type": "local",
      "command": ["{env:HOME}/stack/craft-cli/deckcraft-cli", "mcp"],
      "enabled": true,
      "timeout": 120000
    },
    "pdfcraft": {
      "type": "local",
      "command": ["{env:HOME}/stack/craft-cli/pdfcraft-cli", "mcp"],
      "enabled": true,
      "timeout": 120000
    }
  }
}
CONF

# Подставляем вычисленные Wolfram-пути (heredoc кавыченный ради {env:HOME})
sed -i '' \
    -e "s|__WOLFRAM_BIN__|$WOLFRAM_BIN|g" \
    -e "s|__SCHEMA__|\$schema|g" \
    -e "s|__WOLFRAM_BASE__|$WOLFRAM_BASE|g" \
    "$TARGET/.opencode/opencode.json"

# Валидация JSON

echo "  Конфиг OpenCode: $TARGET/.opencode/opencode.json"
