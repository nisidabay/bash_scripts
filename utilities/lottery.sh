#!/usr/bin/env bash
#
# Random lottery numbers

declare -gA seen=()   # Associative array to track used numbers
declare -gi count=0   # Counter for generated numbers
declare -ga nums=()   # Indexed array to store results

while (( count < 6 )); do
    random_number=$(( RANDOM % 49 + 1 ))  # Random number between 1 and 49

    if [[ -z "${seen[$n]}" ]]; then
        seen["$random_number"]=1
        nums+=("$random_number")
        ((count++)) || true
    fi
done

# Output: Join array with dashes (e.g., "5-12-23-41-7-49")
echo "${nums[*]}" | tr ' ' '-'
