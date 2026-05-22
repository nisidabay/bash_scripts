#!/usr/bin/env bash
#
# Split a string based on space using IFS.
#
# Dependencies: bash

text="Welcome to LinuxHint"

read -a strarray <<<"$text"

echo "There are ${#strarray[@]} words in the text"

for word in "${strarray[@]}"; do
    printf "%s\n" "$word"
done
