#!/bin/bash

# Directory containing the VPN config files
CONFIG_DIR="/mnt/F/Programs/VPN/configs"

# List files starting with "airvpn" and store them in an array
mapfile -t files < <(ls "$CONFIG_DIR" | grep '^airvpn')

# Check if there are any matching files
if [ ${#files[@]} -eq 0 ]; then
    echo "No files starting with 'airvpn' found in $CONFIG_DIR"
    exit 1
fi

# Display the files with numbers
echo "Select a VPN configuration file:"
for i in "${!files[@]}"; do
    echo "$((i+1))) ${files[i]}"
done

# Prompt for user input (1, 2, or 3)
read -p "Enter 1, 2, or 3: " choice

# Validate input
if [[ ! "$choice" =~ ^[1-3]$ ]]; then
    echo "Invalid input. Please enter 1, 2, or 3."
    exit 1
fi

# Convert choice to array index (0-based)
index=$((choice-1))

# Check if the index is valid
if [ "$index" -ge "${#files[@]}" ]; then
    echo "Invalid selection. Only ${#files[@]} files available."
    exit 1
fi

# Execute the selected file with openvpn
selected_file="${files[index]}"
sudo openvpn --config "$CONFIG_DIR/$selected_file"
