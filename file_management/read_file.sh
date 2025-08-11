#!/bin/bash

# Read file if not provided read from stdin
# Similar to "cat"

while read -r file
do
	echo "$file"
done < "${1:-/dev/stdin}"
