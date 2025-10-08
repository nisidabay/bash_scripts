#!/usr/bin/env bash

# Mutiplication table generator with formatted output.
# Usage: ./multiplication_table.sh [size]
# If size is not provided, it defaults to 10.

size=${1:-10}
#
# Number of hyphens
readonly SEPARATOR=4

# Print column frame
printf "   |"
for ((i = 1; i <= size; i++)); do
  printf "%4d" "$i"
done

# print row frame
printf "\n"
printf -- "---+"
for ((i = 1; i <= size * SEPARATOR; i++)); do
  printf "-"
done
printf "\n"

# Print table
for ((i = 1; i <= size; i++)); do
  printf "%2d |" "$i"
  for ((j = 1; j <= size; j++)); do
    printf "%4d" "$((i * j))"
  done
  printf "\n"
done

printf "\nFinished\n"
