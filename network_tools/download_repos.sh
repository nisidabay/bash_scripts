#!/usr/bin/bash
#
# Download repositories from a file
while read -r line ; do
    git clone "$line"
done < "repos_file.txt"

