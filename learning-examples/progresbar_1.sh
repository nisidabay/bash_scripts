#!/usr/bin/env bash
#
# Simple terminal progress bar example.
#
# Dependencies: none
total=50

# Loop over the iterations and update the progress bar
for i in $(seq 1 $total); do
	# Calculate the percentage completion
	pct=$((i * 100 / total))

	# Calculate the number of hashes and spaces to display
	n_hashes=$((i * 50 / total))
	n_spaces=$((50 - n_hashes))

	# Print the progress bar
	printf "\r[%s%s] %d%%" "$(printf '#%.0s' $(seq 1 $n_hashes))" "$(printf ' %.0s' $(seq 1 $n_spaces))" "$pct"

	# Sleep for a short time to simulate work being done
	sleep 0.1
done

# Print a newline to prevent the progress bar from being overwritten
echo ""
