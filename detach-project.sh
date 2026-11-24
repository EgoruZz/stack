#!/bin/bash
# Detach the stack from a project
# Usage: bash detach-project.sh <path-to-project>
#
# What it does:
#   1. Removes .opencode/ from the project (the agent no longer sees the stack)
#   2. Removes the stack section (STACK:START/END) from the project AGENTS.md
#   3. Removes the project from the projects.txt registry
# Project contents (code, files) are not touched.

set -euo pipefail

STACK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REGISTRY="$STACK_DIR/projects.txt"

if [ $# -eq 0 ]; then
    echo "Usage: $0 <path-to-project>"
    exit 1
fi

INPUT_DIR="$1"
case "$INPUT_DIR" in
    "~") INPUT_DIR="$HOME" ;;
    "~/"*) INPUT_DIR="$HOME/${INPUT_DIR#\~/}" ;;
esac

if [ ! -d "$INPUT_DIR" ]; then
    # Folder moved/deleted — detach is still possible: clean the registry only.
    echo "⚠️ Folder does not exist: $INPUT_DIR"
    echo "   Detaching the registry entry only (no config exists on disk)."
    if [ -f "$REGISTRY" ] && grep -qxF "$INPUT_DIR" "$REGISTRY"; then
        grep -vxF "$INPUT_DIR" "$REGISTRY" > "$REGISTRY.tmp" && mv "$REGISTRY.tmp" "$REGISTRY"
        echo "  ✅ Removed from projects.txt"
        exit 0
    else
        echo "  ℹ️ Not in the registry — nothing to do"
        exit 0
    fi
fi
PROJECT_DIR=$(cd "$INPUT_DIR" && pwd)

if [ "$PROJECT_DIR" = "$STACK_DIR" ]; then
    echo "❌ Cannot detach the stack itself"
    exit 1
fi

echo "=== Detaching the stack: $PROJECT_DIR ==="

# 1. OpenCode config
if [ -d "$PROJECT_DIR/.opencode" ]; then
    rm -rf "$PROJECT_DIR/.opencode"
    echo "  ✅ .opencode/ removed (MCP and skills no longer visible in this folder)"
else
    echo "  ℹ️ No .opencode/ present"
fi

# 2. AGENTS.md: remove the stack section if present
AGENTS="$PROJECT_DIR/AGENTS.md"
if [ -f "$AGENTS" ] && grep -q "STACK:START" "$AGENTS"; then
    python3 - "$AGENTS" << 'PYEOF'
import re, sys
p = sys.argv[1]
s = open(p).read()
s2 = re.sub(r'<!-- STACK:START -->.*?<!-- STACK:END -->\n?', '', s, flags=re.DOTALL)
open(p, 'w').write(s2)
print("  ✅ stack section removed from AGENTS.md (the rest of the file is preserved)")
PYEOF
else
    echo "  ℹ️ AGENTS.md has no stack section"
fi

# 3. Registry
if [ -f "$REGISTRY" ] && grep -qxF "$PROJECT_DIR" "$REGISTRY"; then
    grep -vxF "$PROJECT_DIR" "$REGISTRY" > "$REGISTRY.tmp" && mv "$REGISTRY.tmp" "$REGISTRY"
    echo "  ✅ Removed from projects.txt"
else
    echo "  ℹ️ Was not in the registry"
fi

echo ""
echo "✅ Done: the stack is detached from $PROJECT_DIR"
echo "   Re-attach: bash $STACK_DIR/new-project.sh $PROJECT_DIR"
