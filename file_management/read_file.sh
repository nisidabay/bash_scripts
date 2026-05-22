#!/usr/bin/env bash
#
# Read file or stdin line by line.
#
# Dependencies: bash

while read -r file; do
    echo "$file"
done <"${1:-/dev/stdin}"
