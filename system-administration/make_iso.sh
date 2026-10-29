#!/usr/bin/env bash
#
# Create a bootable ISO image.
#
# Dependencies: mkisofs

# Function to display a simple progress bar
progress_bar() {
    local duration=${1}
    for ((elapsed = 1; elapsed <= duration; elapsed++)); do
        printf "▇"
        sleep 1
    done
    printf '\n'
}

# Prompting user for the path of the bootable image
read -p -r "Enter the path of the bootable image: " boot_image

# Checking if the input file exists
if [[ ! -f "$boot_image" ]]; then
    echo "Bootable image not found. Please check the file path."
    exit 1
fi

# Setting other options
boot_catalog="boot.cat"
output_file="/cd.iso"
source_directory="/CD"

# Displaying the chosen options
echo "Creating an ISO with the following parameters:"
echo "Bootable Image: $boot_image"
echo "Boot Catalog: $boot_catalog"
echo "Output File: $output_file"
echo "Source Directory: $source_directory"

# Creating the ISO (in the background) and showing a progress bar
echo "Creating ISO..."
mkisofs -b "$boot_image" -c "$boot_catalog" -J -l -R -r -o "$output_file" "$source_directory" &

# Assuming ISO creation takes around 10 seconds (adjust as needed)
progress_duration=10
progress_bar $progress_duration

wait # Wait for the background mkisofs process to complete

echo "ISO creation complete. File is located at $output_file"
