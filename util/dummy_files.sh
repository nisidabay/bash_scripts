#!/usr/bin/env bash
#
# Create dummy files and add information to them.
#
# Dependencies: touch, date

create_files() {
    local num_files=$1
    for ((i = 1; i <= num_files; i++)); do
        touch "File_$i.txt"
    done
    echo "$num_files files created"
}

read -rp "Number of files: " NUM
if [[ $NUM =~ ^[0-9]+$ ]]; then
    create_files "$NUM"
else
    echo "Invalid input. Please enter a positive integer."
fi

for ((i = 1; i <= NUM; i++)); do
    FILE="File_$i.txt"
    echo "$(date)" >>"$FILE"
done
