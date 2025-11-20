#!/bin/bash
while true; do
    if xdotool search --onlyvisible --fullscreen >/dev/null 2>&1; then
        ddcutil setvcp 10 100 --display 2
    else
        ddcutil setvcp 10 25 --display 2
    fi
    sleep 1
done
