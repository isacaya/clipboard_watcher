# clipboard_watcher, Based on TruffleHog (https://github.com/trufflesecurity/trufflehog)

LAST_CLIPBOARD=""

while true; do
    CLIPBOARD_DATA=$(pbpaste)

    if [[ "$CLIPBOARD_DATA" == "$LAST_CLIPBOARD" || -z "$CLIPBOARD_DATA" ]]; then
        sleep 0.2
        continue
    fi

    TMP_FILE=$(mktemp)
    echo "$CLIPBOARD_DATA" > "$TMP_FILE"

    RESULT=$(trufflehog filesystem --concurrency=1 -j --log-level=-1 "$TMP_FILE")

    DETECTOR_NAME=$(echo "$RESULT" | jq -r '.DetectorName')
    RAW=$(echo "$RESULT" | jq -r '.Raw')

    if [[ -n "$RESULT" ]]; then
        osascript -e "display notification \"$RAW\" with title \"🚨 $DETECTOR_NAME secret detected in clipboard!\""
    fi

    rm "$TMP_FILE"
    LAST_CLIPBOARD="$CLIPBOARD_DATA"
    sleep 0.2
done