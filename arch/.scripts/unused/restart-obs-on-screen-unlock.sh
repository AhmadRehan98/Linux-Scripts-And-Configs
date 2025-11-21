#!/bin/bash

# Path to your OBS script
OBS_SCRIPT="$HOME/.scripts/restart-obs.sh"

# Log file for debugging
LOG_FILE="$HOME/.scripts/screen_lock_trigger.log"



# File to store the last execution timestamp
LAST_EXEC_TIMESTAMP="$HOME/.scripts/last_obs_exec_timestamp"

# Grace period in seconds (1 minute)
GRACE_PERIOD=60

nohup bash "$OBS_SCRIPT" >> "$LOG_FILE" 2>&1 &

# Ensure the OBS script is executable
chmod +x "$OBS_SCRIPT"

# Empty old logs
truncate -s 0 "$LOG_FILE"

# Function to log messages
log_message() {


            echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"




}

# Check if dbus-monitor is available
if ! command -v dbus-monitor >/dev/null; then
    log_message "Error: dbus-monitor not found. Please install dbus."
    exit 1
fi

log_message "Starting D-Bus monitor for KDE screen lock/unlock events..."

# Monitor the org.freedesktop.ScreenSaver interface (used by KDE)
dbus-monitor --session "type='signal',interface='org.freedesktop.ScreenSaver'" | while read -r line; do
    # Check for unlock event (ActiveChanged signal with false)
    if echo "$line" | grep -q "member=ActiveChanged"; then
        read -r next_line
        if echo "$next_line" | grep -q "boolean false"; then
            # Check if we're within the grace period
            CURRENT_TIME=$(date +%s)
            LAST_TIME=0

            # Read the last execution time if the file exists
            if [ -f "$LAST_EXEC_TIMESTAMP" ]; then
                LAST_TIME=$(cat "$LAST_EXEC_TIMESTAMP")
            fi

            # Calculate time since last execution
            TIME_DIFF=$((CURRENT_TIME - LAST_TIME))

            if [ "$TIME_DIFF" -ge "$GRACE_PERIOD" ]; then
                log_message "Screen unlocked detected. Running OBS script in detached mode..."
                # Run the OBS script in a fully detached manner
                nohup bash "$OBS_SCRIPT" >> "$LOG_FILE" 2>&1 &
                # Disown the process to ensure it's independent of this script
                disown
                log_message "OBS script executed (detached)."

                # Update the last execution timestamp

                    echo "$CURRENT_TIME" > "$LAST_EXEC_TIMESTAMP"


            else
                log_message "Screen unlocked detected, but within grace period ($TIME_DIFF seconds since last execution). Skipping OBS script."
            fi
        elif echo "$next_line" | grep -q "boolean true"; then
            log_message "Screen locked detected."
        fi
    fi
done
