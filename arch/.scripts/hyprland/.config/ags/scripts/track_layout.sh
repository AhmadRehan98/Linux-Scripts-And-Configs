#!/bin/bash
# Save as ~/.config/ags/scripts/track_layout.sh
touch /tmp/current_layout
echo "us" > /tmp/current_layout
while true; do
    current=$(hyprctl devices | grep -A 1 "active keymap" | grep "active keymap" | sed 's/.*active keymap: //')
    case "$current" in
        *"English"*) echo "us" ;;
        *"Arabic"*) echo "ar" ;;
        *) echo "us" ;;
    esac > /tmp/current_layout
    sleep 1
done &
