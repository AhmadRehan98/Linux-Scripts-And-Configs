#!/bin/bash
# Whitelist of program name substrings
WHITELIST=("vlc" "osu" "mpv" "The Last of Us" "Cyberpunk" "heroic" "FINAL FANTASY VII REBIRTH" "KingdomCome")

while true; do
    PROGRAM_RUNNING_AND_FOCUSED=false

    # Step 1: Check if any whitelisted program is running
    PROGRAM_RUNNING=false
    for PROGRAM in "${WHITELIST[@]}"; do
        if pgrep "$PROGRAM" > /dev/null; then
            PROGRAM_RUNNING=true
            echo "Found running program matching: $PROGRAM"
            break
        fi
    done

    # Step 2: If a program is running, check if it's focused
    if $PROGRAM_RUNNING; then
        # Get the active window's ID
        ACTIVE_WINDOW_ID=$(kdotool getactivewindow 2>/dev/null)
        if [ -n "$ACTIVE_WINDOW_ID" ]; then
            # Get the active window's name
            ACTIVE_WINDOW_NAME=$(kdotool getwindowname "$ACTIVE_WINDOW_ID" 2>/dev/null)
            if [ -n "$ACTIVE_WINDOW_NAME" ]; then
                echo "Active window: $ACTIVE_WINDOW_NAME"
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
    fi

    # Step 3: Adjust brightness
    if $PROGRAM_RUNNING_AND_FOCUSED; then
        ddcutil setvcp 10 100 --display 2
        echo "Set brightness to 100 - Whitelisted program is running and focused"
    else
        ddcutil setvcp 10 25 --display 2
        echo "Set brightness to 25 - No whitelisted program is running or focused"
    fi
    sleep 2
done
