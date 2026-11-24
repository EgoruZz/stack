#!/bin/bash
# Create a new project or register an existing one to use the stack
# Usage: $STACK_DIR/new-project.sh <path>
# Examples:
#   $STACK_DIR/new-project.sh ~/projects/my-calculation   # create new
#   $STACK_DIR/new-project.sh ~/learn                      # register existing
#   $STACK_DIR/new-project.sh ~/work/analysis              # create anywhere

set -euo pipefail

STACK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REGISTRY="$STACK_DIR/projects.txt"
AGENTS_SRC="$STACK_DIR/AGENTS.md"

if [ $# -eq 0 ]; then
    echo "Usage: $0 <path>"
    echo "Examples:"
    echo "  $0 ~/projects/my-calculation   # create a new project"
    echo "  $0 ~/learn                     # register an existing one"
    exit 1
fi

# Expand ~ to an absolute path (no eval, for safety)
INPUT_DIR="$1"
case "$INPUT_DIR" in
    "~") INPUT_DIR="$HOME" ;;
    "~/"*) INPUT_DIR="$HOME/${INPUT_DIR#\~/}" ;;
esac

# Create the directory if it does not exist
if [ ! -d "$INPUT_DIR" ]; then
    mkdir -p "$INPUT_DIR"
    echo "✅ Folder created: $INPUT_DIR"
else
    echo "📁 Folder already exists: $INPUT_DIR"
fi
PROJECT_DIR=$(cd "$INPUT_DIR" && pwd)

# Make sure it is not the stack itself
if [ "$PROJECT_DIR" = "$(cd "$STACK_DIR" && pwd)" ]; then
    echo "❌ Cannot register the stack itself as a project"
    exit 1
fi

# Copy AGENTS.md if missing
if [ ! -f "$PROJECT_DIR/AGENTS.md" ]; then
    cp "$AGENTS_SRC" "$PROJECT_DIR/AGENTS.md"
    echo "📄 AGENTS.md copied"
else
    echo "📄 AGENTS.md already exists (sync updates the stack section)"
fi

# Generate the OpenCode config (.opencode/opencode.json) — stack MCP/skills
bash "$STACK_DIR/gen-opencode-config.sh" "$PROJECT_DIR"
echo "🔧 OpenCode config generated (the stack activates in this project)"

# Register in projects.txt
mkdir -p "$STACK_DIR"
touch "$REGISTRY"

# Duplicate check (expand ~ in existing entries)
ALREADY_REGISTERED=false
while IFS= read -r line; do
    [[ "$line" =~ ^[[:space:]]*# ]] && continue
    [[ -z "${line// }" ]] && continue
    EXPANDED="$line"
    case "$EXPANDED" in
        "~") EXPANDED="$HOME" ;;
        "~/"*) EXPANDED="$HOME/${EXPANDED#\~/}" ;;
    esac
    if [ "$EXPANDED" = "$PROJECT_DIR" ]; then
        ALREADY_REGISTERED=true
        break
    fi
done < "$REGISTRY"

if [ "$ALREADY_REGISTERED" = true ]; then
    echo "📋 Project already registered"
else
    echo "$PROJECT_DIR" >> "$REGISTRY"
    echo "📋 Project registered in projects.txt"
fi

echo ""
echo "✅ Done: $PROJECT_DIR"
echo ""
echo "Next steps:"
echo "  cd $PROJECT_DIR"
echo "  opencode  # start the AI"
echo ""
echo "AGENTS.md sync:"
echo "  bash $STACK_DIR/sync-agents.sh"
