#!/usr/bin/env bash
#
# Get specific files from a directory.
#
# Dependencies: bash

img_dir=$HOME/Templates
file_types=(jpg png)

files=()

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
