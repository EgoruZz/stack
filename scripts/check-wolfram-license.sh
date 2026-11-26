#!/bin/bash
# Check the Wolfram Engine license (macOS)
# Run: cd $STACK_DIR && bash check-wolfram-license.sh
# Note: uses the macOS-specific command date -j -f

STACK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
echo "=== Wolfram license check ==="
echo ""

# Get the expiry date — formatted BY Wolfram itself (robust to upstream
# output-format changes); fallback to the legacy {y,m,d} parse.
EXPIRY=$(wolframscript -code 'Print[DateString[$LicenseExpirationDate, {"Year","-","Month","-","Day"}]]' 2>/dev/null | grep -oE '^[0-9]{4}-[0-9]{2}-[0-9]{2}$')
if [ -z "$EXPIRY" ]; then
    LEGACY=$(wolframscript -code 'Print[$LicenseExpirationDate]' 2>/dev/null | grep -o '{[0-9, ]*}' | tr -d '{}' | tr ',' ' ')
    YEAR=$(echo $LEGACY | awk '{print $1}'); MONTH=$(echo $LEGACY | awk '{print $2}'); DAY=$(echo $LEGACY | awk '{print $3}')
    EXPIRY="$YEAR-$(printf '%02d' "$MONTH")-$(printf '%02d' "$DAY")"
fi

if [ -z "$EXPIRY" ]; then
    echo "❌ Could not get license information"
    echo "   The license may not be activated"
    echo "   Activate: wolframscript"
    exit 1
fi

# Extract the date components
YEAR=${EXPIRY%%-*}
REST=${EXPIRY#*-}
MONTH=${REST%%-*}
DAY=${REST#*-}

echo "Expiry date: $DAY.$MONTH.$YEAR"

# Build the date for calculation
EXPIRY_DATE=$(date -j -f "%Y-%m-%d" "$EXPIRY" +%s 2>/dev/null)
TODAY=$(date +%s)

if [ -n "$EXPIRY_DATE" ] && [ -n "$TODAY" ]; then
    DIFF=$(( ($EXPIRY_DATE - $TODAY) / 86400 ))
    
    if [ "$DIFF" -lt 0 ]; then
        echo ""
        echo "❌ License expired!"
        echo "   Renew the license: https://www.wolfram.com/engine/"
    elif [ "$DIFF" -lt 30 ]; then
        echo ""
        echo "⚠️  Less than 30 days until the license expires!"
        echo "   Renew the license: https://www.wolfram.com/engine/"
    else
        echo ""
        echo "✅ License valid ($DIFF days left)"
    fi
else
    echo ""
    echo "⚠️  Could not compute the number of days"
    echo "   Check the date manually: wolframscript -code 'Print[$LicenseExpirationDate]'"
fi

echo ""
echo "=== Done ==="
