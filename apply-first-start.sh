#!/bin/bash
# Применяет заполненную форму первого старта (first-start.txt).
# Запуск:  bash ~/stack/apply-first-start.sh [путь-к-форме]
# По умолчанию ищет ~/stack/first-start.txt (копия шаблона с данными).

set -uo pipefail

FORM="${1:-$HOME/stack/first-start.txt}"
SECRETS="$HOME/.stack-secrets.sh"

[ -f "$FORM" ] || { echo "Форма не найдена: $FORM"; echo "Скопируй шаблон: cp ~/stack/first-start.template.txt ~/stack/first-start.txt и заполни."; exit 1; }

# Парсим форму строка за строкой (не source!): пробелы в значениях и
# пропущенные кавычки не должны ломать разбор; хвостовые # комментарии срезаем.
FORM_VARS=""
while IFS= read -r line || [ -n "$line" ]; do
    line="${line%%#*}"            # срезаем комментарий
    line="${line%"${line##*[![:space:]]}"}"   # trim right
    case "$line" in
        [A-Z_]*=*) ;;
        *) continue ;;
    esac
    key="${line%%=*}"; val="${line#*=}"
    val="${val%\"}"; val="${val#\"}"      # обрезаем опциональные кавычки
    val="${val%\'}"; val="${val#\'}"
    eval "$key=\$val"
    export "$key"
done < "$FORM"

MISSING=""
for v in PROXY_HOST PROXY_USER PROXY_PASS PROXY_EXPIRES GIT_NAME GIT_EMAIL WOLFRAM_ID WOLFRAM_PASS; do
    eval "test -n \"\${$v+x}\" || $v=''"   # не задано в форме -> пусто (без set -u abort)
    eval "val=\${$v}"
    case "$v" in PROXY_*) [ -z "$val" ] && MISSING="$MISSING $v" ;; esac
done
if [ -n "$MISSING" ]; then
    echo "❌ Не заполнены обязательные поля:$MISSING (блок прокси)"
    exit 1
fi

# ~/.stack-secrets.sh
cat > "$SECRETS" << EOF
# Сгенерировано apply-first-start.sh из first-start.txt $(date +%F)
PROXY_HOST="$PROXY_HOST"
PROXY_USER="$PROXY_USER"
PROXY_PASS="$PROXY_PASS"
PROXY_EXPIRES="$PROXY_EXPIRES"
EOF
chmod 600 "$SECRETS"
echo "✅ $SECRETS записан (600)"

# git identity
if [ -n "${GIT_NAME:-}" ] && [ -n "${GIT_EMAIL:-}" ]; then
    git config --global user.name "$GIT_NAME"
    git config --global user.email "$GIT_EMAIL"
    echo "✅ git identity: $GIT_NAME <$GIT_EMAIL>"
else
    echo "⚠️ git identity не заполнен — коммиты будут от системного имени"
fi

# Wolfram ID — сохраняем в защищённый файл для будущей активации
if [ -n "${WOLFRAM_ID:-}" ] && [ -n "${WOLFRAM_PASS:-}" ]; then
    cat > "$HOME/.stack-wolfram.conf" << EOF
WOLFRAM_ID="$WOLFRAM_ID"
WOLFRAM_PASS="$WOLFRAM_PASS"
EOF
    chmod 600 "$HOME/.stack-wolfram.conf"
    echo "✅ Wolfram ID сохранён (~/.stack-wolfram.conf, 600) — активация: wolframscript -activate"
else
    echo "ℹ️ Wolfram ID не заполнен (опционально)"
fi

echo ""
echo "Готово. Проверка: bash ~/stack/proxy.sh test && bash ~/stack/check-all.sh"
echo "Файл формы $FORM можно удалить (в нём секреты)."
