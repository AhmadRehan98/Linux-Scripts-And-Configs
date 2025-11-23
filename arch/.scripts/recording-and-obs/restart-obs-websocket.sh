#!/bin/bash

VENV_DIR="./.obs-websocket-venv"
OBS_PROCESS="obs"
log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

# Create the venv only if the directory doesn't already exist
if [ ! -d "$VENV_DIR" ]; then
    log_message "Creating a python venv to install websocket-client just this once"
    python -m venv "$VENV_DIR"
    "$VENV_DIR/bin/pip" install websocket-client &
    PID=$!
    wait $PID

fi
# Run your script using the venv's Python
log_message "Running the python obs websocket shutdown script"
"$VENV_DIR/bin/python" shutdown-obs-websocket.py &
PID=$!
wait $PID

while pgrep -x "$OBS_PROCESS" > /dev/null
do
    sleep 1
done

log_message "Obs shutdown python script finished"
nohup obs --startreplaybuffer --minimize-to-tray --disable-shutdown-check >/tmp/obs_start.log 2>&1 &
disown
log_message "Obs successfully started again"
