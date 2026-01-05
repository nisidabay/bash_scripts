#!/usr/bin/env bash
#
# Generate random ip numbers
random_ip() {
	local limit="$1"

	[[ "$limit" != [0-9] ]] && {
		echo "Expect one digit number"
		exit 1
	}
	for ((i = 0; i < "$limit"; i++)); do
		printf "%d.%d.%d.%d\n" $((RANDOM % 255 + 1)) $((RANDOM % 255 + 1)) $((RANDOM % 255 + 1)) $((RANDOM % 255 + 1))

	done
}

random_ip "$1"
