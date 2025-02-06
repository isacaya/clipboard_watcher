#!/bin/bash
# clipboard_watcher with hash-based change detection (using cksum)

LAST_HASH=""

while true; do
    # Get the current clipboard contents
    CLIPBOARD_DATA=$(pbpaste)
    
    # If clipboard is empty, just sleep and try again.
    if [[ -z "$CLIPBOARD_DATA" ]]; then
        sleep 0.2
        continue
    fi

    # Compute a fast native hash of the clipboard data.
    # 'cksum' outputs two numbers; we only care about the first (the checksum).
    CURRENT_HASH=$(echo "$CLIPBOARD_DATA" | cksum | awk '{print $1}')

    # If the hash hasn't changed, skip running trufflehog.
    if [[ "$CURRENT_HASH" == "$LAST_HASH" ]]; then
        sleep 0.2
        continue
    fi

    # Save the new clipboard content to a temporary file for scanning.
    TMP_FILE=$(mktemp)
    echo "$CLIPBOARD_DATA" > "$TMP_FILE"

    # Run TruffleHog on the file and capture the JSON result.
    RESULT=$(trufflehog filesystem --concurrency=1 -j --log-level=-1 "$TMP_FILE")

    # Remove the temporary file.
    rm "$TMP_FILE"

    # Extract details from the JSON output.
    DETECTOR_NAME=$(echo "$RESULT" | jq -r '.DetectorName')
    RAW=$(echo "$RESULT" | jq -r '.Raw')

    # If a result was found, display a macOS notification.
    if [[ -n "$RESULT" ]]; then
        osascript -e "display notification \"$RAW\" with title \"🚨 $DETECTOR_NAME secret detected in clipboard!\""
    fi

    # Update the last seen hash.
    LAST_HASH="$CURRENT_HASH"

    sleep 0.2
done
