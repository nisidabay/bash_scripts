#!/usr/bin/env bash

# Function to create files and add information to them

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

# Add information to the files
for ((i = 1; i <= NUM; i++)); do
	FILE="File_$i.txt"
	echo "$(date)" >>"$FILE"
done
