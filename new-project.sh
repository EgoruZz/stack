#!/bin/bash
# Создание нового проекта
# Использование: ~/stack/new-project.sh <имя>
# Пример: ~/stack/new-project.sh my-calculation

NAME=$1

if [ -z "$NAME" ]; then
    echo "Использование: $0 <имя>"
    echo "Пример: $0 my-calculation"
    exit 1
fi

PROJECT_DIR=~/projects/"$NAME"

if [ -d "$PROJECT_DIR" ]; then
    echo "❌ Папка уже существует: $PROJECT_DIR"
    exit 1
fi

# Создаём папку
mkdir -p "$PROJECT_DIR"

# Копируем AGENTS.md
cp ~/stack/AGENTS.md "$PROJECT_DIR/"

echo "✅ Проект создан: $PROJECT_DIR"
echo ""
echo "Следующие шаги:"
echo "  cd $PROJECT_DIR"
echo "  code .  # открыть в VS Code"
echo "  opencode  # запустить AI"
