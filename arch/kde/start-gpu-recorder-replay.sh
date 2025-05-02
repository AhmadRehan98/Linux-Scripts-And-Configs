#!/bin/sh
flatpak run com.dec05eba.gpu_screen_recorder


# sleep 5s
# pidof -q flatpak run com.dec05eba.gpu_screen_recorder && exit 1
# video_path="/home/ahmad/Videos/Recordings/Obs Linux/"
# replay_length_s=1200 # replay length in seconds (300sec=5min)
# mkdir -p "$video_path"
# flatpak run com.dec05eba.gpu_screen_recorder -w screen -f 60 -a "`pactl get-default-source`|`pactl get-default-sink`.monitor" -c mkv -r $replay_length_s -o "$video_path" &
# sleep 1s
# if pidof flatpak run com.dec05eba.gpu_screen_recorder >/dev/null
# then
# 	qdbus org.kde.kglobalaccel /component/plasmashell invokeShortcut "toggle do not disturb" # Toggle "do not disturb" mode so that it's back on because screencasting automatically turns it off
# 	notify-send --icon=com.dec05eba.gpu_screen_recorder -- "GPU Screen Recorder" "Replay started"
# # 	zenity --info --text="Replay started successfully" --icon="com.dec05eba.gpu_screen_recorder"
# else
# 	zenity --warning --text="Replay failed to start" --icon="com.dec05eba.gpu_screen_recorder"
# fi
