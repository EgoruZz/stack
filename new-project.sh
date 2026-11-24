#!/bin/bash
# Создание или регистрация проекта использующего стек
# Использование: $STACK_DIR/new-project.sh <путь>
# Примеры:
#   $STACK_DIR/new-project.sh ~/projects/my-calculation   # создать новый
#   $STACK_DIR/new-project.sh ~/learn                      # зарегистрировать существующий
#   $STACK_DIR/new-project.sh ~/work/analysis              # создать в любом месте

set -euo pipefail

STACK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REGISTRY="$STACK_DIR/projects.txt"
AGENTS_SRC="$STACK_DIR/AGENTS.md"

if [ $# -eq 0 ]; then
    echo "Использование: $0 <путь>"
    echo "Примеры:"
    echo "  $0 ~/projects/my-calculation   # создать новый проект"
    echo "  $0 ~/learn                     # зарегистрировать существующий"
    exit 1
fi

# Разворачиваем ~ в абсолютный путь (без eval для безопасности)
INPUT_DIR="$1"
case "$INPUT_DIR" in
    "~") INPUT_DIR="$HOME" ;;
    "~/"*) INPUT_DIR="$HOME/${INPUT_DIR#\~/}" ;;
esac

# Если директории нет — создаём
if [ ! -d "$INPUT_DIR" ]; then
    mkdir -p "$INPUT_DIR"
    echo "✅ Папка создана: $INPUT_DIR"
else
    echo "📁 Папка уже существует: $INPUT_DIR"
fi
PROJECT_DIR=$(cd "$INPUT_DIR" && pwd)

# Проверяем что это не сам стек
if [ "$PROJECT_DIR" = "$(cd "$STACK_DIR" && pwd)" ]; then
    echo "❌ Нельзя зарегистрировать сам стек как проект"
    exit 1
fi

# Копируем AGENTS.md если его нет
if [ ! -f "$PROJECT_DIR/AGENTS.md" ]; then
    cp "$AGENTS_SRC" "$PROJECT_DIR/AGENTS.md"
    echo "📄 AGENTS.md скопирован"
else
    echo "📄 AGENTS.md уже существует (синхронизация обновит stack-секцию)"
fi

# Генерируем конфиг OpenCode (.opencode/opencode.json) — MCP/skills стека
bash "$STACK_DIR/gen-opencode-config.sh" "$PROJECT_DIR"
echo "🔧 Конфиг OpenCode сгенерирован (стек поднимется в этом проекте)"

# Регистрируем в projects.txt
mkdir -p "$STACK_DIR"
touch "$REGISTRY"

# Проверяем на дубликат (раскрываем тильду в существующих записях)
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
    echo "📋 Проект уже зарегистрирован"
else
    echo "$PROJECT_DIR" >> "$REGISTRY"
    echo "📋 Проект зарегистрирован в projects.txt"
fi

echo ""
echo "✅ Готово: $PROJECT_DIR"
echo ""
echo "Следующие шаги:"
echo "  cd $PROJECT_DIR"
echo "  opencode  # запустить AI"
echo ""
echo "Синхронизация AGENTS.md:"
echo "  bash $STACK_DIR/sync-agents.sh"
