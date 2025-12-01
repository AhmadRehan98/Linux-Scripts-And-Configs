#!/bin/bash
OBS_SCRIPT="./restart-obs-websocket.sh"
GRACE_PERIOD=30
chmod +x "$OBS_SCRIPT"

log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}
log_message "Run obs manually for the first time on fresh boot"
bash "$OBS_SCRIPT"
log_message "Starting kscreen-console to listen for screen disconnect/reconnect..."
LAST_TIME=0
LAST_LOG_TIME=0
kscreen-console | while read -r line; do
    if echo "$line" | grep -q -i "connected"; then
        CURRENT_TIME=$(date +%s)
        # Calculate time since last execution
        TIME_DIFF=$((CURRENT_TIME - LAST_TIME))
        if [ "$TIME_DIFF" -ge "$GRACE_PERIOD" ]; then
            LAST_TIME=$CURRENT_TIME
            log_message "Screen wakeup detected. Running OBS script in detached mode"
            # Run the OBS script synchronously
            bash "$OBS_SCRIPT"
            log_message "Obs child script finished"
        else
            CURRENT_TIME=$(date +%s)
            if [ "$((CURRENT_TIME - LAST_LOG_TIME))" -ge "$((GRACE_PERIOD / 3))" ]; then
                log_message "Screen wakeup detected, but within grace period ($TIME_DIFF seconds since last execution). Skipping OBS script"
            fi
            LAST_LOG_TIME=$CURRENT_TIME
        fi
    fi
done
