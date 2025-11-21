#!/bin/bash

# File to store unique window names
OUTPUT_FILE="/home/ahmad/.scripts/unique_windows.txt"

# Ensure the output file exists
touch "$OUTPUT_FILE"

while true; do
    # Get the active window's ID
    ACTIVE_WINDOW_ID=$(kdotool getactivewindow 2>/dev/null)
    if [ -n "$ACTIVE_WINDOW_ID" ]; then
        # Get the active window's name
        ACTIVE_WINDOW_NAME=$(kdotool getwindowname "$ACTIVE_WINDOW_ID" 2>/dev/null)
        if [ -n "$ACTIVE_WINDOW_NAME" ]; then
            echo "Active window: $ACTIVE_WINDOW_NAME"
            # Check if this window name is already in the file
            if ! grep -Fx "$ACTIVE_WINDOW_NAME" "$OUTPUT_FILE" >/dev/null; then
                # Append the new unique window name to the file
                echo "$ACTIVE_WINDOW_NAME" >> "$OUTPUT_FILE"
                echo "Logged new window name: $ACTIVE_WINDOW_NAME"
            fi
            # Check if the window name matches any whitelist entry
            for PROGRAM in "${WHITELIST[@]}"; do
                if echo "$ACTIVE_WINDOW_NAME" | grep -qi "$PROGRAM"; then
                    PROGRAM_RUNNING_AND_FOCUSED=true
                    echo "Program $PROGRAM is focused (Window: $ACTIVE_WINDOW_NAME)"
                    break
                fi
            done
        else
            echo "Could not get active window name"
        fi
    else
        echo "Could not get active window ID"
    fi
    sleep 2
done
