#!/bin/bash
# Sync the stack section of AGENTS.md into every registered project
# Reads the registry from $STACK_DIR/projects.txt (one path per line)
# Replaces ONLY the content between STACK:START and STACK:END
# Project-specific content is preserved
# Usage:
#   bash sync-agents.sh              # sync + restart hint
#   bash sync-agents.sh --no-hint    # no hint (called from update-all.sh)
#   bash sync-agents.sh --prune      # also drop registry paths that no longer exist
#   bash sync-agents.sh --discover   # + auto-discover projects by the
#                                    #   .opencode/opencode.json marker and
#                                    #   add them to the registry

set -uo pipefail

STACK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
STACK_TEMPLATE="$STACK_DIR/AGENTS.template.md"
REGISTRY="$STACK_DIR/projects.txt"

if [ ! -f "$STACK_TEMPLATE" ]; then
    echo "ERROR: $STACK_TEMPLATE not found"
    exit 1
fi

if ! grep -q "STACK:START" "$STACK_TEMPLATE"; then
    echo "ERROR: STACK:START/END markers not found in $STACK_TEMPLATE"
    exit 1
fi

# Substitute the real stack path: AGENTS.template.md keeps {{STACK}} —
# on sync every project (and the stack itself) gets the actual path.
STACK_AGENTS="$(mktemp)"
trap 'rm -f "$STACK_AGENTS"' EXIT
sed "s|{{STACK}}|$STACK_DIR|g" "$STACK_TEMPLATE" > "$STACK_AGENTS"

# Render AGENTS.md for sessions inside the stack itself (gitignored, local)
sed "s|{{STACK}}|$STACK_DIR|g" "$STACK_TEMPLATE" > "$STACK_DIR/AGENTS.md"

if ! grep -q "STACK:START" "$STACK_AGENTS"; then
    echo "ERROR: STACK:START/END markers not found in $STACK_AGENTS"
    exit 1
fi

if [ ! -f "$REGISTRY" ]; then
    if [ -f "$STACK_DIR/projects.template.txt" ]; then
        cp "$STACK_DIR/projects.template.txt" "$REGISTRY"
        echo "  projects.txt created from the template (empty — add projects: $STACK_DIR/new-project.sh <path>)"
    else
        echo "ERROR: registry $REGISTRY not found and no template present"
        echo "  Create it: $STACK_DIR/new-project.sh <path>"
        exit 1
    fi
fi

echo "=== Syncing AGENTS.md and OpenCode configs ==="
echo ""

# --discover: auto-discovery — find projects by the marker
# .opencode/opencode.json (created by new-project.sh) and add
# them to the registry. The stack itself is excluded.
if [ "${1:-}" = "--discover" ] || [ "${2:-}" = "--discover" ]; then
    echo "── Auto-discovering projects (marker: .opencode/opencode.json)..."
    FOUND=$(find "$HOME" -maxdepth 4 -type d -name .opencode -not -path "*/node_modules/*" -not -path "$STACK_DIR/*" -not -path "*/Library/*" -not -path "*/.Trash/*" 2>/dev/null | sed 's|/.opencode$||' | sort -u)
    ADDED=0
    while IFS= read -r d; do
        [ -z "$d" ] && continue
        [ -f "$d/.opencode/opencode.json" ] || continue
        if ! grep -qxF "$d" "$REGISTRY" 2>/dev/null; then
            echo "$d" >> "$REGISTRY"
            echo "  + discovered and added: $d"
            ADDED=$((ADDED + 1))
        fi
    done <<EOF
$FOUND
EOF
    echo "  newly added: $ADDED"
    echo ""
fi

if [ "${1:-}" = "--prune" ] || [ "${2:-}" = "--prune" ]; then
    if [ -f "$REGISTRY" ]; then
        PRUNED=0
        REG_SNAPSHOT=$(mktemp)
        trap 'rm -f "$REG_SNAPSHOT"' EXIT
        cp "$REGISTRY" "$REG_SNAPSHOT"
        while IFS= read -r line; do
            [[ "$line" =~ ^[[:space:]]*# ]] && continue
            [[ -z "${line// }" ]] && continue
            P="$line"
            case "$P" in
                "~") P="$HOME" ;;
                "~/"*) P="$HOME/${P#\~/}" ;;
            esac
            if [ ! -d "$P" ]; then
                grep -vxF "$line" "$REGISTRY" > "$REGISTRY.tmp" && mv "$REGISTRY.tmp" "$REGISTRY"
                echo "  - removed dead entry: $line"
                PRUNED=$((PRUNED + 1))
            fi
        done < "$REG_SNAPSHOT"
        rm -f "$REG_SNAPSHOT"
        echo "  dead registry entries removed: $PRUNED"
        echo ""
    fi
fi

SYNCED=0
CREATED=0
CONFIGURED=0
MISSING=0
SEEN=$(mktemp)

# The stack own config (for sessions in $STACK_DIR) — regenerate from the template
bash "$STACK_DIR/scripts/gen-opencode-config.sh" "$STACK_DIR" >/dev/null 2>&1 \
    && echo "  $STACK_DIR/.opencode/opencode.json: regenerated" \
    || echo "  ⚠️ config for $STACK_DIR not generated"

while IFS= read -r project || [ -n "$project" ]; do
    # Skip comments and empty lines
    [[ "$project" =~ ^[[:space:]]*# ]] && continue
    [[ -z "${project// }" ]] && continue

    # Expand ~ to an absolute path (no eval)
    case "$project" in
        "~") project="$HOME" ;;
        "~/"*) project="$HOME/${project#\~/}" ;;
    esac

    # Deduplication
    if grep -qxF "$project" "$SEEN" 2>/dev/null; then
        continue
    fi
    echo "$project" >> "$SEEN"

    if [ ! -d "$project" ]; then
        echo "  $project: folder not found — skipping"
        MISSING=$((MISSING + 1))
        continue
    fi

    # OpenCode config (.opencode/opencode.json) — the project gets the stack MCP/skills.
    # The stack activates only where this file is generated.
    if bash "$STACK_DIR/scripts/gen-opencode-config.sh" "$project" >/dev/null 2>&1; then
        CONFIGURED=$((CONFIGURED + 1))
    else
        echo "  $project: ⚠️ OpenCode config not generated"
    fi

    AGENTS="$project/AGENTS.md"

    # If AGENTS.md is missing — copy from the stack
    if [ ! -f "$AGENTS" ]; then
        cp "$STACK_AGENTS" "$AGENTS"
        echo "  $AGENTS: created from $STACK_DIR/AGENTS.md"
        CREATED=$((CREATED + 1))
        continue
    fi

    if grep -q "STACK:START" "$AGENTS" 2>/dev/null; then
        # Markers present — replace between them
        python3 - "$AGENTS" "$STACK_AGENTS" << 'PYEOF'
import re, sys

agents_path, stack_path = sys.argv[1], sys.argv[2]

with open(stack_path) as f:
    stack = f.read()
with open(agents_path) as f:
    content = f.read()

match = re.search(r'<!-- STACK:START -->.*?<!-- STACK:END -->', stack, re.DOTALL)
if not match:
    print(f'  {agents_path}: STACK:START/END not found in the source')
    sys.exit(1)

stack_section = match.group()
content = re.sub(
    r'<!-- STACK:START -->.*?<!-- STACK:END -->',
    stack_section, content, flags=re.DOTALL
)
with open(agents_path, 'w') as f:
    f.write(content)
print(f'  {agents_path}: synced')
PYEOF
        SYNCED=$((SYNCED + 1))
    else
        # No markers — insert the stack section after the header (# AGENTS.md)
        python3 - "$AGENTS" "$STACK_AGENTS" << 'PYEOF'
import re, sys

agents_path, stack_path = sys.argv[1], sys.argv[2]

with open(stack_path) as f:
    stack = f.read()
with open(agents_path) as f:
    content = f.read()

stack_match = re.search(r'<!-- STACK:START -->.*?<!-- STACK:END -->', stack, re.DOTALL)
if not stack_match:
    print(f'  {agents_path}: STACK:START/END not found in the source')
    sys.exit(1)

stack_section = stack_match.group()

# Find the end of the header (# AGENTS.md) and insert the stack section after it
lines = content.split('\n')
insert_idx = 0
for i, line in enumerate(lines):
    if line.startswith('# '):
        insert_idx = i + 1
        break
# Skip empty lines after the header
while insert_idx < len(lines) and not lines[insert_idx].strip():
    insert_idx += 1

new_lines = lines[:insert_idx] + stack_section.split('\n') + [''] + lines[insert_idx:]
with open(agents_path, 'w') as f:
    f.write('\n'.join(new_lines))
print(f'  {agents_path}: markers added, synced')
PYEOF
        SYNCED=$((SYNCED + 1))
    fi
done < "$REGISTRY"

rm -f "$SEEN"

echo ""
echo "=== Done! ==="
echo "  AGENTS.md synced: $SYNCED"
echo "  AGENTS.md created: $CREATED"
echo "  OpenCode configs generated: $CONFIGURED"
echo "  Not found (folder removed): $MISSING"

# Restart hint (hidden by the --no-hint flag for update-all.sh)
if [ "${1:-}" != "--no-hint" ]; then
    echo ""
    echo "IMPORTANT: restart OpenCode to apply the changes!"
    echo "  Quit all open OpenCode sessions and start again."
fi
