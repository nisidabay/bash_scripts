#!/usr/bin/bash
#
# Split a string based on character without IFS
text="Davinci's code:Dan Brown:25$"

# Append the splitted words into an array
readarray -d: strarray <<< "$text"

echo "There are ${#strarray[@]} words in the text"

for (( v=0; v<=${#strarray[@]}; v++ ))
do
    printf "%s\n" "${strarray[$v]}"
done

