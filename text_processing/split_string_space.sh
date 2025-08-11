#!/usr/bin/bash
#
# Split a string based on space using IFS by default
text="Welcome to LinuxHint"

# Append the splitted words into an array
# read -a strarray <<< "$text"
read -a strarray <<< "$text"

echo "There are ${#strarray[@]} words in the text"

for word in "${strarray[@]}";do
    printf "%s\n" "$word"
done


