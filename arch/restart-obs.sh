#!/bin/bash

# Configuration
USE_FLATPAK=1
OBS_PROCESS="obs"
FLATPAK_OBS="com.obsproject.Studio"
CLEAR_CONFIG=0

# Prevent script exit on errors
trap '' ERR

# Function to check if OBS is running
is_obs_running() {
    if [ "$USE_FLATPAK" -eq 1 ]; then
        ps aux | grep -E "[o]bs --startreplaybuffer --minimize-to-tray" > /dev/null
    else
        pgrep -x "$OBS_PROCESS" > /dev/null
    fi
}

# Function to get OBS PIDs
get_obs_pids() {
    if [ "$USE_FLATPAK" -eq 1 ]; then
        PIDS=$(ps aux | grep -E "[o]bs --startreplaybuffer --minimize-to-tray" | grep -v grep | awk '{print $2}' || true)
    else
        PIDS=$(pgrep -x "$OBS_PROCESS" || true)
    fi
    echo "$PIDS"
}

# Function to close OBS gracefully
close_obs() {
    if is_obs_running; then
        echo "Attempting to close OBS gracefully..."
        if [ "$USE_FLATPAK" -eq 1 ]; then
            flatpak kill "obs --startreplaybuffer --minimize-to-tray" 2>/dev/null || true
        else
            if command -v wmctrl >/dev/null; then
                wmctrl -c "OBS" 2>/dev/null || true
                sleep 2
            fi
        fi

        # Fallback: Force close if still running
        local PIDS
        PIDS=$(get_obs_pids)
        if [ -n "$PIDS" ]; then
            echo "Graceful close failed. Force-closing OBS PIDs: $PIDS"
            for PID in $PIDS; do
                kill -TERM "$PID" 2>/dev/null || true
            done
        fi
    else
        echo "OBS not running."
    fi
}

# Function to clear OBS configuration (resets crash detection)
clear_obs_config() {
    if [ "$CLEAR_CONFIG" -eq 1 ]; then
        echo "Clearing OBS configuration to prevent Safe Mode prompt..."
        CONFIG_DIR="$HOME/.var/app/$FLATPAK_OBS/config/obs-studio"
        if [ -d "$CONFIG_DIR" ]; then
            echo "Backing up OBS config to $CONFIG_DIR.bak..."
            mv "$CONFIG_DIR" "$CONFIG_DIR.bak" 2>/dev/null || true
        fi
    fi
}

# Close OBS if running
echo "Checking for running OBS..."
if is_obs_running; then
    echo "OBS is running. Closing it..."
    close_obs
else
    echo "OBS not running."
fi

# Wait for OBS to exit (up to 15 seconds)
echo "Waiting for OBS to close..."
for i in {1..15}; do
    if ! is_obs_running; then
        echo "OBS closed successfully."
        break
    fi
    PIDS=$(get_obs_pids)
    echo "OBS still running (PIDs: $PIDS, attempt $i/15)..."
    sleep 1
done

# Ensure OBS is closed
if is_obs_running; then
    echo "❌ Failed to close OBS. PIDs: $(get_obs_pids)"
    exit 1
fi

# Clear OBS config if requested
clear_obs_config

# Start OBS with --disable-shutdown-check in a fully detached manner
echo "Starting OBS in detached mode..."
if [ "$USE_FLATPAK" -eq 1 ]; then
    nohup flatpak run "$FLATPAK_OBS" --startreplaybuffer --minimize-to-tray --disable-shutdown-check >/tmp/obs_start.log 2>&1 &
    disown
else
    nohup obs --disable-shutdown-check >/tmp/obs_start.log 2>&1 &
    disown
fi
OBS_PID=$!

# Wait for OBS to start
sleep 3

# Check if OBS started
if is_obs_running; then
    echo "✅ OBS started successfully (PID: $OBS_PID)."
else
    echo "❌ Failed to start OBS. See /tmp/obs_start.log."
    cat /tmp/obs_start.log
    exit 1
fi
