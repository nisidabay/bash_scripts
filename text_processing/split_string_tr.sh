#!/usr/bin/env bash
#
# Split a string using tr.
#
# Dependencies: tr

text="Dan Brown wrote Davinci's Code"

array=($(echo "$text" | tr ' ' '\n'))

echo "There are ${#array[@]} words in the text"

for ((v = 0; v <= ${#array[@]}; v++)); do
    printf "%s\n" "${array[$v]}"
done
