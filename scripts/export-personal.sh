#!/bin/bash
# Collect the stack personal files (excluded from git) into one folder —
# for backup or migration to another machine.
#
# Usage:
#   bash export-personal.sh [target-folder]
#   # default: ~/stack-personal-backup-YYYY-MM-DD/
#
# Collects (if they exist):
#   projects.txt      — project registry
#   first-start.txt   — filled first-start form
#   ~/.stack-secrets.sh — personal data (proxy, Wolfram ID, git identity)
#   ~/skills/         — tldraw-offline helper (installed by the tldraw app)

set -euo pipefail

STACK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DEST="${1:-$HOME/stack-personal-backup-$(date +%F)}"

if [ -e "$DEST" ] && [ -n "$(ls -A "$DEST" 2>/dev/null)" ]; then
    echo "❌ Target folder is not empty: $DEST — choose another one"
    exit 1
fi
mkdir -p "$DEST"

COPIED=0
copy() {
    if [ -e "$1" ]; then
        cp -R "$1" "$DEST/" && echo "  ✅ $1" && COPIED=$((COPIED + 1))
    else
        echo "  ℹ️ missing: $1"
    fi
}

echo "=== Collecting stack personal data → $DEST ==="
copy "$STACK_DIR/projects.txt"
copy "$STACK_DIR/first-start.txt"
copy "$HOME/.stack-secrets.sh"
copy "$HOME/skills"

echo ""
echo "✅ Done ($COPIED items): $DEST"
echo ""
echo "Restore on another machine (after setup.sh):"
echo "  cp <folder>/projects.txt <folder>/first-start.txt \$STACK_DIR/"
echo "  cp <folder>/.stack-secrets.sh ~/"
echo "  cp -R <folder>/skills ~/   # if tldraw-offline was present"
echo "  bash \$STACK_DIR/scripts/apply-first-start.sh"
echo "  bash \$STACK_DIR/scripts/sync-agents.sh"
