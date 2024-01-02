#!/usr/bin/bash

k Prompt the user for the path to the USB drive
read -p "Enter the path to your USB drive: " -r usb_path

# Check if the provided path is not empty
if [[ -z "$usb_path" ]]; then
    echo "No path entered. Exiting the script."
    exit 1
fi

# Check if the provided path exists
if [[ ! -d "$usb_path" ]]; then
    echo "The provided path does not exist. Exiting the script."
    exit 1
fi

# Applying the immutable attribute to all files in the specified path
echo "Applying the immutable attribute to all files in $usb_path"
find "$usb_path" -type f -exec sudo chattr +i {} \;

echo "Operation completed."
