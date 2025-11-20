#!/usr/bin/env python3

import subprocess
import time
import os

FULLSCREEN_BRIGHTNESS = 100
NORMAL_BRIGHTNESS = 20
SLEEP_TIME = 0.5

IGNORED_CLASSES = {
    "firefox", "chromium", "brave", "google-chrome",
    "opera", "vivaldi", "vivaldi-stable", "chrome"
}

ALLOWED_CLASSES = {
    "mpv"
}


def get_focused_window_wayland():
    try:
        output = subprocess.check_output([
            "busctl", "--user", "--no-pager", "call",
            "org.freedesktop.portal.Desktop",
            "/org/freedesktop/portal/desktop",
            "org.freedesktop.portal.ActiveWindow", "GetActiveWindow", ""
        ])
        # Format: "s \"win32:ID\""
        return output.decode().split('"')[1]
    except Exception as e:
        print("[!] Could not get active window:", e)
        return None


def get_window_class_wayland():
    try:
        output = subprocess.check_output([
            "busctl", "--user", "--no-pager", "call",
            "org.freedesktop.portal.Desktop",
            "/org/freedesktop/portal/desktop",
            "org.freedesktop.portal.WindowIdentifier", "GetWindowAppId", "s", "win32:0"
        ])
        return output.decode().split('"')[1].lower()
    except Exception as e:
        print("[!] Failed to get window class via portal:", e)
        return None


def is_full_resolution_wayland():
    try:
        screen_res = subprocess.check_output("loginctl show-session $(loginctl | grep $(whoami) | awk '{print $1}') -p Active --value", shell=True).decode().strip()
        if screen_res != "yes":
            return False

        # Fallback check - best effort
        screen_info = subprocess.check_output("loginctl show-session $(loginctl | grep $(whoami) | awk '{print $1}')", shell=True).decode()
        return True if "Active=yes" in screen_info else False
    except Exception as e:
        print("[!] Resolution check failed:", e)
        return False


def set_brightness(level):
    try:
        subprocess.run(["ddcutil", "setvcp", "10", str(level), "--display", "2"], check=True)
        print(f"[+] Set brightness to {level}%")
    except Exception as e:
        print("[!] Brightness error:", e)


def main():
    print("⚡ Wayland Fullscreen Brightness Watcher started.")
    was_fullscreen = False

    while True:
        class_name = get_window_class_wayland()
        if not class_name:
            time.sleep(SLEEP_TIME)
            continue

        is_fullres = is_full_resolution_wayland()
        print(f"[DEBUG] Class: {class_name}, Full-res: {is_fullres}")

        if class_name in ALLOWED_CLASSES and is_fullres:
            if not was_fullscreen:
                set_brightness(FULLSCREEN_BRIGHTNESS)
                was_fullscreen = True
        elif class_name not in IGNORED_CLASSES and is_fullres:
            if not was_fullscreen:
                set_brightness(FULLSCREEN_BRIGHTNESS)
                was_fullscreen = True
        else:
            if was_fullscreen:
                set_brightness(NORMAL_BRIGHTNESS)
                was_fullscreen = False

        time.sleep(SLEEP_TIME)


if __name__ == "__main__":
    main()
