#!/usr/bin/bash
#
# Split a string based on character using IFS
text="Davinci's code:Dan Brown:25$"

OLDIFS=$IFS
IFS=':'

# Append the splitted words into an array
read -a strarray <<< "$text"

echo "There are ${#strarray[@]} words in the text"

for (( v=0; v<=${#strarray[@]}; v++ ))
do
    printf "%s\n" "${strarray[$v]}"
done

IFS=$OLDIFS
