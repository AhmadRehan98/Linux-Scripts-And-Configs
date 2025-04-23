#!/bin/bash

# Wait until the KDE Plasma session is running
while ! pgrep -u "$USER" plasmashell >/dev/null; do
    sleep 1
done

# Wait a little extra for stability
sleep 5

# Restart services
systemctl --user restart pipewire wireplumber xdg-desktop-portal

# run obs
unset XDG_DESKTOP_PORTAL
flatpak run com.obsproject.Studio --startreplaybuffer --minimize-to-tray "$@"
