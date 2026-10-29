#!/usr/bin/env bash
#
# Generate a multiplication table.
#
# Dependencies: bash

size=${1:-10}
readonly SEPARATOR=4

printf "   |"
for ((i = 1; i <= size; i++)); do
    printf "%4d" "$i"
done

printf "\n"
printf -- "---+"
for ((i = 1; i <= size * SEPARATOR; i++)); do
    printf "-"
done
printf "\n"

for ((i = 1; i <= size; i++)); do
    printf "%2d |" "$i"
    for ((j = 1; j <= size; j++)); do
        printf "%4d" "$((i * j))"
    done
    printf "\n"
done

printf "\nFinished\n"
