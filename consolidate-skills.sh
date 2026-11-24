#!/bin/bash
# Consolidate all skills into $STACK_DIR/skills-store (single store)
# Skills are attached to projects via skills.paths in .opencode/opencode.json —
# global directories (~/.config/opencode/skills, ~/.claude/skills,
# ~/.config/opencode/skills is emptied completely; ~/.claude/skills and
# ~/.agents/skills are cleaned selectively — only skills that already
# exist in the store are moved; other tools' foreign skills are untouched).
#
# Called by setup.sh and update-all.sh. Safe to run repeatedly.
#
# Usage: bash consolidate-skills.sh

set -uo pipefail

STACK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STORE="$STACK_DIR/skills-store"
ARIS_REPO="$STACK_DIR/aris-research-repo"
ARIS_LIST="$STACK_DIR/aris-skills.txt"

mkdir -p "$STORE"

# ── 1. Standalone skills from the repo (8) ──
cp -R "$STACK_DIR/skills/"* "$STORE/" 2>/dev/null || true

# ── 2. ARIS skills from the clone (list: aris-skills.txt) ──
if [ -d "$ARIS_REPO/skills" ] && [ -f "$ARIS_LIST" ]; then
    while IFS= read -r skill || [ -n "$skill" ]; do
        [[ "$skill" =~ ^[[:space:]]*# ]] && continue
        [[ -z "${skill// }" ]] && continue
        skill="${skill// /}"
        [ -d "$ARIS_REPO/skills/$skill" ] && rsync -a --delete \
            "$ARIS_REPO/skills/$skill/" "$STORE/$skill/" 2>/dev/null
    done < "$ARIS_LIST"
fi

# ── 3. tldraw skills ──
# tldraw-offline: canonical source — ~/skills/tldraw-offline (installed
# by the tldraw Desktop app together with the tq.mjs helper; SKILL.md
# references exactly this path).
if [ -d "$HOME/skills/tldraw-offline" ]; then
    rsync -aL "$HOME/skills/tldraw-offline/" "$STORE/tldraw-offline/" 2>/dev/null
elif [ ! -d "$STORE/tldraw-offline" ] && [ -d "$HOME/.config/opencode/skills/tldraw-offline" ]; then
    mv "$HOME/.config/opencode/skills/tldraw-offline" "$STORE/tldraw-offline"
fi
# ── 4. Move skills from global directories (e.g. after firecrawl init) ──
# ~/.config/opencode/skills — OpenCode's own directory: copy everything and
# clear it completely (skills must not be visible outside projects).
# ~/.claude/skills and ~/.agents/skills — directories of OTHER AI tools:
# update and delete only the skills that already live in skills-store
# (known sources: firecrawl, ARIS, standalone, tldraw). Foreign/unknown
# skills are not touched — neither pulled into the store nor deleted from global dirs.
gdir="$HOME/.config/opencode/skills"
[ -d "$gdir" ] && rsync -aL "$gdir/" "$STORE/" 2>/dev/null

for gdir in "$HOME/.claude/skills" "$HOME/.agents/skills"; do
    [ -d "$gdir" ] || continue
    ls "$gdir" 2>/dev/null | while IFS= read -r name; do
        [ -n "$name" ] || continue
        # Known sources: already in the store, or firecrawl skills
        if [ -d "$STORE/$name" ] || [ "$name" = "firecrawl" ] || [ "${name#firecrawl-}" != "$name" ]; then
            rsync -aL "$gdir/$name/" "$STORE/$name/" 2>/dev/null
            rm -rf "$gdir/$name"
        fi
    done
done

# ── 5. Garbage collection in the store (BEFORE cleaning global dirs!) ──
# Remove from skills-store everything that no longer exists in any source
# (e.g. renamed/deleted standalone skills). Names from global directories
# are counted here because those directories themselves are removed in step 6.
KEEP=$(mktemp)
{ ls "$STACK_DIR/skills" 2>/dev/null;
  grep -v '^\s*#' "$ARIS_LIST" 2>/dev/null | tr -d ' ';
  echo tldraw-offline;
  ls "$HOME/.config/opencode/skills" 2>/dev/null;
  ls "$HOME/.claude/skills" 2>/dev/null;
  ls "$HOME/.agents/skills" 2>/dev/null; } | sort -u > "$KEEP"
for d in "$STORE"/*; do
    name=$(basename "$d")
    # firecrawl skills — known source, always kept
    if grep -qxF "$name" "$KEEP" || [ "$name" = "firecrawl" ] || [ "${name#firecrawl-}" != "$name" ]; then
        continue
    fi
    rm -rf "$d"
done
rm -f "$KEEP"

# ── 6. Clean the global OpenCode directory ──
rm -rf "$HOME/.config/opencode/skills"

COUNT=$(ls "$STORE" 2>/dev/null | wc -l | tr -d ' ')
echo "  Skills store: $STORE ($COUNT skills), global directories cleaned"
