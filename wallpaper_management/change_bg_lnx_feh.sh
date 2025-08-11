#!/usr/bin/bash
#
# Author: https://gumirov.xyz/
# Description: Change background image on i3wm 
# Modified on: mar 17 ene 2023 08:08:01 CET, by ChatGPT
# Dependencies: feh

# Define the display
export DISPLAY=":0"

# Define the directory with wallpapers
bg_dir="$HOME/Pictures"

# Create the directory if it doesn't exist
if [ ! -d "$bg_dir" ]; then
    mkdir -p "$bg_dir"
fi

# Define the name of the current background image file
current_bg_image="current_bg_image.png"

# Get the number of images in the directory
bg_num=$(find "$bg_dir" -maxdepth 1 -type f | wc -l)

if [ "$bg_num" -ne 0 ]; then
    # Remove the current background image
    [ -f "$bg_dir/$current_bg_image" ] && rm "$bg_dir/$current_bg_image"

    # Get a random image from the directory
    selected_bg=$(find "$bg_dir" -maxdepth 1 -type f | shuf -n 1)

    # Create a symbolic link to the selected image with the name "current_bg_image.png"
    ln -s "$selected_bg" "$bg_dir/$current_bg_image"

    # Refresh the wallpaper
    feh --bg-fill "$bg_dir/$current_bg_image"
else
    echo "No image files found in $bg_dir"
    exit 1
fi

