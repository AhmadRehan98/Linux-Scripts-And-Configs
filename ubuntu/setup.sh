#!/usr/bin/env bash

usage() {
  echo "please only enter either y or n"
  install_or_skip $1 $2 $3
}

install_or_skip() {
  echo "$1 $2? y/n"
  read -r answer
  if [ $answer = "y" ]; then
    echo "$1ing $2"
    eval $3
  elif [ $answer = "n" ]; then 
    echo "Skipping $2"
  else usage $1 $2 $3
  fi
}
sudo apt update
sudo apt-get install curl git 

install_or_skip "Add" "arabic language to inputs" "gsettings set org.gnome.desktop.input-sources sources \"[('xkb', 'us'), ('xkb', 'ara')]\"; gsettings set org.gnome.desktop.wm.keybindings switch-input-source \"['<Alt>Shift_L', '<Alt>Shift_R', '<Shift>Alt_L', '<Shift>Alt_R']\"; gsettings set org.gnome.desktop.input-sources xkb-options \"['grp:alt_shift_toggle', 'grp:lalt_lshift_toggle', 'grp:ralt_rshift_toggle', 'lv3:ralt_alt']\""

install_or_skip "Set" "touchpad scrolling direction up=up and down=down" "gsettings set org.gnome.desktop.peripherals.touchpad natural-scroll false"
install_or_skip "Set" "click on start bar minimizes or previews" "gsettings set org.gnome.shell.extensions.dash-to-dock click-action 'minimize-or-previews'"
install_or_skip "Set" "dark mode/theme" "gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'"

install_or_skip "Install" "vscode" "sudo snap install --classic code"
install_or_skip "Install" "microsoft teams" "sudo snap install --classic teams-for-linux"
install_or_skip "Install" "postman" "sudo snap install --classic postman"
install_or_skip "Install" "microsoft edge" "curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg; sudo install -o root -g root -m 644 microsoft.gpg /etc/apt/trusted.gpg.d/; sudo sh -c 'echo \"deb [arch=amd64] https://packages.microsoft.com/repos/edge stable main\" > /etc/apt/sources.list.d/microsoft-edge-dev.list'; sudo rm microsoft.gpg; sudo apt update; sudo apt-get install microsoft-edge-stable"
install_or_skip "Install" "gnome tweaks" "sudo add-apt-repository universe; sudo apt-get install gnome-tweaks"
install_or_skip "Install" "github desktop" "wget -qO - https://apt.packages.shiftkey.dev/gpg.key | gpg --dearmor | sudo tee /usr/share/keyrings/shiftkey-packages.gpg > /dev/null; sudo sh -c 'echo \"deb [arch=amd64 signed-by=/usr/share/keyrings/shiftkey-packages.gpg] https://apt.packages.shiftkey.dev/ubuntu/ any main\" > /etc/apt/sources.list.d/shiftkey-packages.list'; sudo apt update; sudo apt-get install github-desktop"
