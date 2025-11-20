#!/usr/bin/env python3

import os
os.environ["LC_ALL"] = "C.UTF-8"  # Fix Qt locale warning

import subprocess
import time

SCRIPT_PATH = "/home/ahmad/.scripts/restart-obs.sh"

def get_screen_states():
    try:
        out = subprocess.check_output(["kscreen-doctor"], text=True)
        return out
    except Exception as e:
        print(f"Error: {e}")
        return ""

def any_screen_off(output):
    return "enabled: false" in output or "connected: false" in output or "Dpms: Off" in output

was_off = False

print("[*] Monitoring screen state...")

while True:
    state = get_screen_states()
    if any_screen_off(state):
        was_off = True
    elif was_off:
        print("[+] Screen came back on, running script!")
        subprocess.Popen(["bash", SCRIPT_PATH])
        was_off = False
    time.sleep(2)
