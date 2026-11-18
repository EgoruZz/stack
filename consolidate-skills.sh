#!/bin/bash
# Консолидация всех скиллов в ~/stack/skills-store (единое хранилище)
# Скиллы подключаются к проектам через skills.paths в .opencode/opencode.json —
# глобальные каталоги (~/.config/opencode/skills, ~/.claude/skills,
# ~/.agents/skills) опустошаются, чтобы скиллы не были видны вне проектов.
#
# Вызывается setup.sh и update-all.sh. Безопасно запускать повторно.
#
# Использование: bash consolidate-skills.sh

set -uo pipefail

STACK_DIR="$HOME/stack"
STORE="$STACK_DIR/skills-store"
ARIS_REPO="$STACK_DIR/aris-research-repo"
ARIS_LIST="$STACK_DIR/aris-skills.txt"

mkdir -p "$STORE"

# ── 1. Standalone-скиллы из репозитория (8) ──
cp -R "$STACK_DIR/skills/"* "$STORE/" 2>/dev/null || true

# ── 2. ARIS-скиллы из клона (список aris-skills.txt) ──
if [ -d "$ARIS_REPO/skills" ] && [ -f "$ARIS_LIST" ]; then
    while IFS= read -r skill || [ -n "$skill" ]; do
        [[ "$skill" =~ ^[[:space:]]*# ]] && continue
        [[ -z "${skill// }" ]] && continue
        skill="${skill// /}"
        [ -d "$ARIS_REPO/skills/$skill" ] && rsync -a --delete \
            "$ARIS_REPO/skills/$skill/" "$STORE/$skill/" 2>/dev/null
    done < "$ARIS_LIST"
fi

# ── 3. tldraw-скиллы ──
# tldraw-offline: канонический источник — ~/skills/tldraw-offline (ставится
# приложением tldraw Desktop вместе с хелпером tq.mjs; SKILL.md ссылается
# именно на этот путь).
if [ -d "$HOME/skills/tldraw-offline" ]; then
    rsync -aL "$HOME/skills/tldraw-offline/" "$STORE/tldraw-offline/" 2>/dev/null
elif [ ! -d "$STORE/tldraw-offline" ] && [ -d "$HOME/.config/opencode/skills/tldraw-offline" ]; then
    mv "$HOME/.config/opencode/skills/tldraw-offline" "$STORE/tldraw-offline"
fi
# tldraw-skill: GitHub или перенос из глобального
if [ ! -d "$STORE/tldraw-skill" ]; then
    if [ -d "$HOME/.config/opencode/skills/tldraw-skill" ]; then
        mv "$HOME/.config/opencode/skills/tldraw-skill" "$STORE/tldraw-skill"
    elif git clone --depth 1 https://github.com/Agents365-ai/tldraw-skill.git \
         /tmp/tldraw-skill-repo 2>/dev/null; then
        rm -rf /tmp/tldraw-skill-repo/.git
        cp -R /tmp/tldraw-skill-repo "$STORE/tldraw-skill"
        rm -rf /tmp/tldraw-skill-repo
    else
        echo "  tldraw-skill: пропущен (GitHub недоступен)"
    fi
fi

# ── 4. Перенос скиллов из глобальных каталогов (напр. после firecrawl init) ──
# firecrawl-cli ставит скиллы в ~/.config/opencode/skills, ~/.claude/skills
# и ~/.agents/skills (часть — симлинки). -L разыменовывает их в реальные файлы.
for gdir in "$HOME/.config/opencode/skills" "$HOME/.claude/skills" "$HOME/.agents/skills"; do
    [ -d "$gdir" ] && rsync -aL "$gdir/" "$STORE/" 2>/dev/null
done

# ── 5. Очистка глобальных каталогов (скиллы не должны быть видны вне проектов) ──
rm -rf "$HOME/.config/opencode/skills" \
       "$HOME/.claude/skills" \
       "$HOME/.agents/skills"

COUNT=$(ls "$STORE" 2>/dev/null | wc -l | tr -d ' ')
echo "  Хранилище скиллов: $STORE ($COUNT скиллов), глобальные каталоги очищены"
