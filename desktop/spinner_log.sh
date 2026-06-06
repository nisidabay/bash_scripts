#!/usr/bin/env bash
#
# Spinner with log file monitoring.
#
# Dependencies: stat, tail

# Path to the log file to monitor.
logfile=/tmp/mylog
# Initialize the size of the log file to 0.
logsize=0
# Time interval in seconds between each spin character update.
spinpause=0.10
# Initialize the length of the last output line to 0.
linelen=0

# Function to output the last line from the log file.
function lastout() {
    # Read the last line from the log file.
    local line=$(tail -n 1 $logfile 2>/dev/null)

    # Check if the line is non-empty.
    if [[ "$line" ]]; then
        # Print the line with a padding of five spaces, without a newline at the end.
        echo -n "     $line"

        # Calculate the number of extra spaces needed to clear out previous output.
        local len=${#line}
        while ((len < linelen)); do
            # Print extra spaces to ensure previous longer lines are fully cleared.
            echo -n " "
            ((len++))
        done

        # Update the length of the current line for the next iteration.
        linelen=${#line}
    fi
}

# Function to output a spinning character indicating activity.
function spinout() {
    # The spinning character to display.
    local spinchar="$1"

    # Check if the log file exists.
    if [[ -f $logfile ]]; then
        # Print the spinning character, overwriting the same line.
        echo -n -e "\r$spinchar"
        # Pause for a short duration.
        sleep $spinpause

        # Check if there is new content in the log file.
        local sz=$(stat --printf '%s' $logfile 2>/dev/null)
        if ((sz > logsize)); then
            # If new content is found, output the last line from the log file.
            lastout
            # Update the stored size of the log file.
            logsize=$sz
        fi
    fi
}

# Check if the log file exists and has content.
if [[ -f $logfile ]]; then
    # Get the initial size of the log file.
    logsize=$(stat --printf '%s' $logfile 2>/dev/null)
    if ((logsize > 0)); then
        # If the file has content, output an initial space and the last line.
        echo -n " "
        lastout
    fi

    # Continuously update the spinning character and check the log file for new content.
    while [[ -f $logfile ]]; do
        # Display different spinning characters to create an animation effect.
        spinout "/"
        spinout "-"
        spinout "\\"
        spinout "|"
    done
    # Move to a new line once the loop ends.
    echo
fi
