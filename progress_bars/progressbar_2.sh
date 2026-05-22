#!/usr/bin/env bash
#
# Visual terminal progress bar.
progress-bar() {
	local duration=${1} # Capture the first argument as the duration of the progress bar.

	# Function: already_done
	# Description: Prints the completed portion of the progress bar.
	already_done() {
		for ((done = 0; done < "$elapsed"; done++)); do
			printf "▇" # Print a block character for each second elapsed.
		done
	}

	# Function: remaining
	# Description: Prints the remaining portion of the progress bar.
	remaining() {
		for ((remain = "$elapsed"; remain < "$duration"; remain++)); do
			printf " " # Print a space for each second remaining.
		done
	}

	# Function: percentage
	# Description: Prints the completion percentage of the progress bar.
	percentage() {
		printf "| %s%%" $(((($elapsed) * 100) / ($duration) * 100 / 100)) # Calculate and print the percentage.
	}

	# Function: clean_line
	# Description: Clears the current line in the terminal.
	clean_line() {
		printf "\r" # Move the cursor back to the beginning of the line.
	}

	# Main loop for the duration of the progress bar.
	for ((elapsed = 1; elapsed <= $duration; elapsed++)); do
		already_done # Print the completed portion.
		remaining    # Print the remaining portion.
		percentage   # Print the completion percentage.
		sleep 1      # Wait for one second to simulate elapsed time.
		clean_line   # Clear the line for the next update.
	done
	clean_line # Clean up the line after completing the progress bar.
}

progress-bar 10
