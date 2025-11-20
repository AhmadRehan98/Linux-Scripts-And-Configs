#!/usr/bin/env python3

import time
import subprocess
import os

BRIGHTNESS_FILE = "/tmp/brightness_command.txt"
CURRENT_LEVEL = None

def set_brightness(level):
    global CURRENT_LEVEL
    if CURRENT_LEVEL == level:
        return
    try:
        subprocess.run(["ddcutil", "setvcp", "10", str(level), "--display", "2"], check=True)
        print(f"[+] Set brightness to {level}%")
        CURRENT_LEVEL = level
    except Exception as e:
        print(f"[!] Brightness error: {e}")

def main():
    print("Fullscreen Brightness Watcher running...")
    while True:
        try:
            if os.path.exists(BRIGHTNESS_FILE):
                with open(BRIGHTNESS_FILE) as f:
                    value = f.read().strip()
                    if value in ("100", "20"):
                        set_brightness(int(value))
        except Exception as e:
            print(f"[!] Error reading file: {e}")
        time.sleep(0.5)

if __name__ == "__main__":
    main()
