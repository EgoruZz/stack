#!/bin/bash
# Doc consistency check — what CONTRIBUTING.md demands, verified automatically.
# Every agent (or CI) runs this instead of hand-counting counters in three docs.
# Run: bash scripts/check-docs.sh   (exit 0 = consistent)

STACK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FAIL=0
bad() { echo "❌ $1"; FAIL=1; }
ok()  { echo "✅ $1"; }

DOCS=("$STACK_DIR/README.md" "$STACK_DIR/STACK.md" "$STACK_DIR/CONTRIBUTING.md" "$STACK_DIR/AGENTS.template.md")
docs_grep() { grep -ho "$1" "${DOCS[@]}" 2>/dev/null | head -1; }

# 1. Every script mentioned in the docs exists; every script is mentioned somewhere
MENTIONED=$(grep -rho 'scripts/[a-z-]*\.sh' "${DOCS[@]}" 2>/dev/null | sort -u)
for m in $MENTIONED; do
    [ -f "$STACK_DIR/$m" ] || bad "docs mention $m — file missing"
done
for f in "$STACK_DIR"/scripts/*.sh; do
    name=$(basename "$f")
    grep -q "$name" "${DOCS[@]}" || bad "scripts/$name is not mentioned in any doc"
done
ok "scripts ↔ docs cross-references"

# 2. Counters match reality
[ "$(ls -d "$STACK_DIR"/skills/*/ 2>/dev/null | wc -l | tr -d ' ')" -eq 8 ] || bad "expected 8 standalone skills in skills/"
[ "$(grep -c '^[a-z]' "$STACK_DIR/aris-skills.txt")" -eq 14 ] || bad "expected 14 entries in aris-skills.txt"
ok "hard counters (8 standalone skills, 14 ARIS)"

# 3. The numbers stated in AGENTS.template.md match the scripts' reality
SETUP_STEPS=$(grep -o '>>> [0-9]*/[0-9]*' "$STACK_DIR/scripts/setup.sh" | tail -1 | cut -d/ -f2)
UPDATE_STEPS=$(grep -o '>>> [0-9]*/[0-9]*' "$STACK_DIR/scripts/update-all.sh" | tail -1 | cut -d/ -f2)
MCP_COUNT=$(grep -E '^    "[A-Za-z]+": \{' "$STACK_DIR/scripts/gen-opencode-config.sh" | grep -cv '"servers"')
grep -q "($SETUP_STEPS steps" "$STACK_DIR/AGENTS.template.md" || bad "setup.sh really has $SETUP_STEPS steps — docs say otherwise"
grep -q "$UPDATE_STEPS steps" "$STACK_DIR/AGENTS.template.md" || bad "update-all.sh really has $UPDATE_STEPS steps — docs say otherwise"
grep -q "10 MCP" "$STACK_DIR/AGENTS.template.md" && [ "$MCP_COUNT" -eq 10 ] || bad "MCP count: config generates $MCP_COUNT, docs say 10"
ok "docs counters match script reality ($SETUP_STEPS setup steps, $UPDATE_STEPS update steps, $MCP_COUNT MCP)"

# 4. Template integrity: placeholder + markers the render pipeline depends on
grep -q '{{STACK}}' "$STACK_DIR/AGENTS.template.md" || bad "AGENTS.template.md lost the {{STACK}} placeholder"
grep -q 'STACK:START' "$STACK_DIR/AGENTS.template.md" || bad "AGENTS.template.md lost STACK:START markers"
[ -f "$STACK_DIR/AGENTS.md" ] && head -3 "$STACK_DIR/AGENTS.md" | grep -qi 'bootstrap\|STACK:START' || bad "AGENTS.md is neither the bootstrap nor a render"
ok "AGENTS template structure ({{STACK}}, STACK markers)"

# 5. Assets referenced in README exist
for a in $(grep -o 'assets/[a-zA-Z0-9_-]*\.[a-z0-9]*' "$STACK_DIR/README.md" | sort -u); do
    [ -f "$STACK_DIR/$a" ] || bad "README references missing asset: $a"
done
ok "README assets exist"

# 6. .gitignore still covers the generated/personal paths
for p in 'projects.txt' 'first-start.txt' 'skills-store' 'craft-cli' '.opencode' '.brew-pre-manifest.txt'; do
    grep -q "^$p" "$STACK_DIR/.gitignore" || bad ".gitignore lost the $p entry"
done
ok ".gitignore entries"

[ "$FAIL" -eq 0 ] && echo "" && echo "=== Docs consistent ===" || { echo ""; echo "=== Docs INCONSISTENT — fix the ❌ rows ==="; }
exit $FAIL
