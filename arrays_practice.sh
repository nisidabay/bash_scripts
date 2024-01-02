#!/usr/bin/bash
###############################################################################
# Author: Carlos Lacaci Moya
# Description: Practicing with associative arrays
# Date: 
# Dependencies:
############################################################################### 
unset temp
declare -A temp

while read host ip; do
        temp[$host]=$ip
done < temp_file

echo "Elements: ${#temp[@]}"
echo "Keys: ${!temp[@]}"
echo "Values: ${temp[@]}"

for key in "${!temp[@]}"; do
    echo "key:   ${key}"
    echo "value: ${temp[$key]}"
done
for key in "${!temp[@]}"; do
    printf "%s\t%s\n" "$key" "${temp[$key]}";
done
