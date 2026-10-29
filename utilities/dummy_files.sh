#!/usr/bin/env bash
#
# Create dummy files and add information to them.
# Date: 2026-10-23

create_files() {
    local num_files="$1"

    for ((i = 1; i <= num_files; i++)); do
        touch "File_$i.txt"
    done
    echo "$num_files files created"
}

read -rp "Number of files: " num
if [[ $num =~ ^[0-9]+$ ]]; then
    create_files "$num"
else
    echo "Invalid input. Please enter a positive integer."
fi

for ((i = 1; i <= num; i++)); do
    file="File_$i.txt"
    "$(date)" >>"$file"
done
