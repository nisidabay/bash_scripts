#!/usr/bin/env bash
#
# Download repositories from a file.
#
# Dependencies: git

while read -r line; do
    git clone "$line"
done <"repos_file.txt"
