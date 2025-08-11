#!/usr/bin/bash
#
# Generate an index of current scripts in this dir
#
# Author: nisidabay
# Date: mar 28 feb 2023 10:36:48 CET
declare -r skip="index.txt"

# Delete old index
[[ -f $skip ]] && rm "$skip"


# Fancy header
printf "%-20s\t%s\n\n" "Script" "Purpose" > "$skip"

# Only the third line _ is read. Skip dirs and text files

for scpt in *; do
    [[ -d "$scpt" ]] && continue
    [[ -L "$scpt" ]] && continue
    [[ ${scpt##*.} == "txt" ]] && continue
    read -r _ _ _ < "$scpt"
    # grep -o. Print only matched non-empty lines
    comment=$(grep -o '#.*' "$scpt" | sed -n '3p')
    printf "%-20s\t%s\n" "$scpt" "$comment" >> index.txt
done
# Format the output using column
column -c 80 "$skip"
