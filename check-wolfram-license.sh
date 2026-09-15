#!/bin/bash
# Проверка лицензии Wolfram Engine (macOS)
# Запуск: cd ~/stack && bash check-wolfram-license.sh
# Примечание: использует macOS-специфичную команду date -j -f

echo "=== Проверка лицензии Wolfram ==="
echo ""

# Получаем дату истечения
EXPIRY=$(wolframscript -code 'Print[$LicenseExpirationDate]' 2>/dev/null | grep -o '{[0-9, ]*}' | tr -d '{}' | tr ',' ' ')

if [ -z "$EXPIRY" ]; then
    echo "❌ Не удалось получить информацию о лицензии"
    echo "   Возможно, лицензия не активирована"
    echo "   Активируйте: wolframscript"
    exit 1
fi

# Извлекаем компоненты даты
YEAR=$(echo $EXPIRY | awk '{print $1}')
MONTH=$(echo $EXPIRY | awk '{print $2}')
DAY=$(echo $EXPIRY | awk '{print $3}')

echo "Дата истечения: $DAY.$MONTH.$YEAR"

# Формируем дату для вычисления
EXPIRY_DATE=$(date -j -f "%Y-%m-%d" "$YEAR-$(printf '%02d' $MONTH)-$(printf '%02d' $DAY)" +%s 2>/dev/null)
TODAY=$(date +%s)

if [ -n "$EXPIRY_DATE" ] && [ -n "$TODAY" ]; then
    DIFF=$(( ($EXPIRY_DATE - $TODAY) / 86400 ))
    
    if [ "$DIFF" -lt 0 ]; then
        echo ""
        echo "❌ Лицензия истекла!"
        echo "   Продлите лицензию: https://www.wolfram.com/engine/"
    elif [ "$DIFF" -lt 30 ]; then
        echo ""
        echo "⚠️  До истечения лицензии осталось менее 30 дней!"
        echo "   Продлите лицензию: https://www.wolfram.com/engine/"
    else
        echo ""
        echo "✅ Лицензия действительна (осталось $DIFF дней)"
    fi
else
    echo ""
    echo "⚠️  Не удалось вычислить количество дней"
    echo "   Проверьте дату вручную: wolframscript -code 'Print[$LicenseExpirationDate]'"
fi

echo ""
echo "=== Готово ==="
