#!/bin/bash
# Генерирует .opencode/opencode.json — конфиг стека (MCP + LSP + plugin)
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

if [ ! -d "$TARGET" ]; then
    echo "ОШИБКА: директория не найдена: $TARGET"
    exit 1
fi

mkdir -p "$TARGET/.opencode"

cat > "$TARGET/.opencode/opencode.json" << 'CONF'
{
  "$schema": "https://opencode.ai/config.json",
  "plugin": ["opencode-firecrawl"],
  "lsp": true,
  "mcp": {
    "Wolfram": {
      "type": "local",
      "command": [
        "/Applications/Wolfram Engine.app/Contents/Resources/Wolfram Player.app/Contents/MacOS/wolfram",
        "-run",
        "PacletSymbol[\"Wolfram/AgentTools\",\"Wolfram`AgentTools`StartMCPServer\"][]",
        "-noinit",
        "-noprompt"
      ],
      "enabled": true,
      "environment": {
        "MCP_SERVER_NAME": "WolframLanguage",
        "WOLFRAM_BASE": "/Library/WolframEngine",
        "WOLFRAM_LOCALBASE": "{env:HOME}/Library/Wolfram/Objects",
        "WOLFRAM_USERBASE": "{env:HOME}/Library/WolframEngine"
      },
      "timeout": 60000
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
    }
  }
}
CONF

# Валидация JSON
python3 -m json.tool "$TARGET/.opencode/opencode.json" > /dev/null

echo "  Конфиг OpenCode: $TARGET/.opencode/opencode.json"
