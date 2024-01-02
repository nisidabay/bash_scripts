#!/bin/bash

dmenu_folder="$HOME/bin/dmenu"
bin_folder="$HOME/bin"

# Ensure the ~/bin folder exists
# mkdir -p "$bin_folder"

# Loop through each file in the dmenu folder
for script_file in "$dmenu_folder"/*; do
    # Check if the file is a shell script (text/x-shellscript)
    file_type=$(file -b --mime-type "$script_file")
    if [[ "$file_type" == "text/x-shellscript" ]]; then
        # Get the filename without the path
        script_name=$(basename "$script_file")

        # Create a symbolic link in ~/bin for the script
        ln -s "$script_file" "$bin_folder/$script_name"

        # Set executable permission on the link
        chmod +x "$bin_folder/$script_name"
    fi
done

echo "Links created in $bin_folder, and executable permissions set for each link."
