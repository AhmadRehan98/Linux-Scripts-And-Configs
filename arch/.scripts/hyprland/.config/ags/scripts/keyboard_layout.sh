#!/bin/bash
current=$(hyprctl devices | grep -A 1 "active keymap" | grep "active keymap" | sed 's/.*active keymap: //')
case "$current" in
    *"English"*) echo "us" ;;
    *"Arabic"*) echo "ar" ;;
    *) echo "us" ;; # Default to us
esac
