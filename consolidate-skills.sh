#!/bin/bash
# Консолидация всех скиллов в ~/stack/skills-store (единое хранилище)
# Скиллы подключаются к проектам через skills.paths в .opencode/opencode.json —
# глобальные каталоги (~/.config/opencode/skills, ~/.claude/skills,
# ~/.config/opencode/skills опустошается полностью; ~/.claude/skills и
# ~/.agents/skills чистятся выборочно — переносятся только скиллы, уже
# существующие в хранилище (чужие скиллы других инструментов не затрагиваются).
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
# ── 4. Перенос скиллов из глобальных каталогов (напр. после firecrawl init) ──
# ~/.config/opencode/skills — собственный каталог OpenCode: копируем всё и
# полностью очищаем (скиллы не должны быть видны вне проектов).
# ~/.claude/skills и ~/.agents/skills — каталоги ДРУГИХ AI-инструментов:
# обновляем и удаляем только те скиллы, что уже живут в skills-store
# (известные источники: firecrawl, ARIS, standalone, tldraw). Чужие/неизвестные
# скиллы не трогаем — не втягиваем их в хранилище и не удаляем из глобальных.
gdir="$HOME/.config/opencode/skills"
[ -d "$gdir" ] && rsync -aL "$gdir/" "$STORE/" 2>/dev/null

for gdir in "$HOME/.claude/skills" "$HOME/.agents/skills"; do
    [ -d "$gdir" ] || continue
    while IFS= read -r name; do
        [ -n "$name" ] || continue
        if [ -d "$STORE/$name" ]; then
            rsync -aL "$gdir/$name/" "$STORE/$name/" 2>/dev/null
            rm -rf "$gdir/$name"
        fi
    done < <(ls "$gdir" 2>/dev/null)
done

# ── 5. Очистка глобального каталога OpenCode ──
rm -rf "$HOME/.config/opencode/skills"

COUNT=$(ls "$STORE" 2>/dev/null | wc -l | tr -d ' ')
echo "  Хранилище скиллов: $STORE ($COUNT скиллов), глобальные каталоги очищены"
