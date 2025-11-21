#!/bin/bash

# Directory containing wallpapers
WALLPAPER_DIR="/mnt/F/Pictures/Make WallPapers Great Again"
# Time interval between wallpaper changes (in seconds)
INTERVAL=6000  # Set to 10 seconds for testing
# Log file for debugging
LOG_FILE="$HOME/.config/hypr/wallpaper_slideshow.log"

# Ensure the log file exists
touch "$LOG_FILE"

# Log start of script
echo "[$(date)] Starting wallpaper slideshow" >> "$LOG_FILE"

# Check if wallpaper directory exists
if [ ! -d "$WALLPAPER_DIR" ]; then
    echo "[$(date)] Error: Wallpaper directory $WALLPAPER_DIR does not exist" >> "$LOG_FILE"
    exit 1
fi

# Get list of wallpapers and store in an array safely
WALLPAPERS=()
while IFS= read -r -d '' file; do
    WALLPAPERS+=("$file")
done < <(find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.png" \) -print0)
TOTAL=${#WALLPAPERS[@]}

# Check if wallpapers are found
if [ $TOTAL -eq 0 ]; then
    echo "[$(date)] Error: No wallpapers found in $WALLPAPER_DIR" >> "$LOG_FILE"
    exit 1
fi

echo "[$(date)] Found $TOTAL wallpapers" >> "$LOG_FILE"

# Main loop to cycle wallpapers
while true; do
    for ((i=0; i<TOTAL; i++)); do
        echo "[$(date)] Setting wallpaper: ${WALLPAPERS[$i]}" >> "$LOG_FILE"
        # Unload previous wallpapers to save memory
        hyprctl hyprpaper unload all >> "$LOG_FILE" 2>&1
        # Preload and set the new wallpaper
        hyprctl hyprpaper preload "${WALLPAPERS[$i]}" >> "$LOG_FILE" 2>&1
        hyprctl hyprpaper wallpaper ",${WALLPAPERS[$i]}" >> "$LOG_FILE" 2>&1
        # Check if the wallpaper command was successful
        if [ $? -ne 0 ]; then
            echo "[$(date)] Error: Failed to set wallpaper ${WALLPAPERS[$i]}" >> "$LOG_FILE"
        fi
        sleep $INTERVAL
    done
done
