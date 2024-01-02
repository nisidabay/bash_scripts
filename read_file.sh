#! /usr/bin/bash

# Read file if not provided read from stdin
# Similar to "cat"

while read file
do
	echo "$file"
done < "${1:-/dev/stdin}"
