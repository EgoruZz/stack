#!/bin/bash
# Sync ARIS skills from the clone into $STACK_DIR/skills-store/
# Skill list: $STACK_DIR/aris-skills.txt (single source of truth)
# Usage:
#   bash sync-aris.sh            # sync only
#   bash sync-aris.sh --update   # git pull the clone + sync

set -uo pipefail

STACK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SKILLS_DIR="$STACK_DIR/skills-store"
ARIS_REPO="$STACK_DIR/aris-research-repo"
ARIS_LIST="$STACK_DIR/aris-skills.txt"

if [ ! -f "$ARIS_LIST" ]; then
    echo "ERROR: $ARIS_LIST not found"
    exit 1
fi

if [ ! -d "$ARIS_REPO/skills" ]; then
    echo "ERROR: $ARIS_REPO/skills not found (clone not installed)"
    echo "  Run: bash $STACK_DIR/scripts/setup.sh"
    exit 1
fi

# --update: update the clone first
if [ "${1:-}" = "--update" ]; then
    (cd "$ARIS_REPO" && git pull --ff-only 2>/dev/null && echo "  ARIS repo updated" || echo "  ARIS repo: already up to date or pull failed")
fi

mkdir -p "$SKILLS_DIR"

SYNCED=0
MISSING=0

while IFS= read -r skill || [ -n "$skill" ]; do
    # Skip comments and empty lines
    [[ "$skill" =~ ^[[:space:]]*# ]] && continue
    [[ -z "${skill// }" ]] && continue

    skill="${skill// /}"

    if [ -d "$ARIS_REPO/skills/$skill" ]; then
        rsync -a --delete "$ARIS_REPO/skills/$skill/" "$SKILLS_DIR/$skill/" 2>/dev/null
        SYNCED=$((SYNCED + 1))
    else
        echo "  $skill: not found in the ARIS repo — skipping"
        MISSING=$((MISSING + 1))
    fi
done < "$ARIS_LIST"

echo "  ARIS skills synced: $SYNCED"
[ "$MISSING" -gt 0 ] && echo "  Not found in the repo: $MISSING (check aris-skills.txt)"
exit 0
