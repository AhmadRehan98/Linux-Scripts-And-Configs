#!/bin/bash

VENV_DIR="./.obs-websocket-venv"

# Create the venv only if the directory doesn't already exist
if [ ! -d "$VENV_DIR" ]; then
    python -m venv "$VENV_DIR"
    "$VENV_DIR/bin/pip" install websocket-client obsws-python &
    PID=$!
    wait $PID
fi

# Run your script using the venv's Python
"$VENV_DIR/bin/python" restart-obs-websocket.py &
PID=$!
wait $PID


OBS_PROCESS="obs"
while pgrep -x "$OBS_PROCESS" > /dev/null
do
    sleep 1
done


# rm -rf /home/$USER/.config/obs-studio/.sentinel;
nohup obs --startreplaybuffer --minimize-to-tray --disable-shutdown-check >/tmp/obs_start.log 2>&1 &
