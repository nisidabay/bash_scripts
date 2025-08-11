#!/usr/bin/bash
#
# Split a string based on character without IFS
text="Dan Brown wrote Davinci's Code"


# Append the splitted words into an array
array=($(echo "$text" | tr ' ' '\n'))

echo "There are ${#array[@]} words in the text"

for (( v=0; v<=${#array[@]}; v++ ))
do
    printf "%s\n" "${array[$v]}"
done

