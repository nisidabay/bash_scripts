#!/usr/bin/bash
#
# Get specific files from a directory
# Date: jue 16 mar 2023 05:02:38 CET

# Declare variables for directory path and file types
img_dir=$HOME/Templates
file_types=(jpg png)

# Declare an empty array for files
files=()

# Function to get a list of all the files in the directory
get_files() {
    for file in "$img_dir"/*."${file_types[@]}"; do
        if [ -f "$file" ]; then
            files+=("$file")
        fi
    done

    if [ ${#files[@]} -eq 0 ]; then
        echo "No files found in $img_dir"
        exit 1
    fi
    exit 0
}

get_files
