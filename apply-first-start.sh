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

# НЕ заданные в форме поля -> пусто (set -u safe)
for v in PROXY_HOST PROXY_USER PROXY_PASS PROXY_EXPIRES GIT_NAME GIT_EMAIL WOLFRAM_ID WOLFRAM_PASS AGENT_SUDO; do
    eval "test -n \"\${$v+x}\" || $v=''"
done
# Прокси ОПЦИОНАЛЕН: либо заполнены все поля блока, либо ни одного
P_EMPTY=0; P_FULL=0
for v in PROXY_HOST PROXY_USER PROXY_PASS; do
    eval "val=\${$v}"
    [ -z "$val" ] && P_EMPTY=$((P_EMPTY+1)) || P_FULL=$((P_FULL+1))
done
if [ "$P_EMPTY" -gt 0 ] && [ "$P_FULL" -gt 0 ]; then
    echo "❌ Блок прокси заполнен наполовину — заполни все PROXY_* поля или оставь пустыми (без прокси)"
    exit 1
fi

# ~/.stack-secrets.sh — только если прокси настроен
if [ "$P_FULL" = "0" ]; then
    rm -f "$SECRETS"
    echo "ℹ️ Прокси не настроен (опционально) — стек работает напрямую"
else
cat > "$SECRETS" << EOF
# Сгенерировано apply-first-start.sh из first-start.txt $(date +%F)
PROXY_HOST="$PROXY_HOST"
PROXY_USER="$PROXY_USER"
PROXY_PASS="$PROXY_PASS"
PROXY_EXPIRES="$PROXY_EXPIRES"
EOF
chmod 600 "$SECRETS"
echo "✅ $SECRETS записан (600)"
fi

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

# Sudo без пароля для агента (опционально)
SUDOERS="/etc/sudoers.d/stack-agent"
SUDOERS_TPL="$HOME/.stack-sudoers.tpl"
if [ "$AGENT_SUDO" = "full" ]; then
    echo "$USER ALL=(ALL) NOPASSWD: ALL" > "$SUDOERS_TPL"
    echo ""
    echo "⚠️  Выбран AGENT_SUDO=full: агент и все процессы от твоего пользователя"
    echo "    получат root без пароля. Если это осознанное решение — выполни:"
    echo "      sudo install -m 440 \"$SUDOERS_TPL\" $SUDOERS"
    echo "    (sudo спросит пароль один раз — дальше у агента sudo будет без пароля)"
    echo "    Отменить: sudo rm -f $SUDOERS && rm -f $SUDOERS_TPL"
elif [ -f "$SUDOERS" ]; then
    echo ""
    echo "ℹ️  Sudoers-файл $SUDOERS существует, но AGENT_SUDO != full."
    echo "    Убрать бессрочный NOPASSWD: sudo rm -f $SUDOERS"
fi

echo "Форма $FORM оставляется на месте: если данные сменятся (другой прокси,"
echo "аккаунт, срок подписки) — просто отредактируй её и запусти снова."
