#!/usr/bin/env bash
#
# Read and display a file line by line.
#
# Dependencies: bash

echo "Enter the file name: "
read -r filename
[ -f "$filename" ] || echo "($filename) does not exist"

while IFS= read -r line; do
    echo "$line"
done <"$filename"
