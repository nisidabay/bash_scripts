#!/usr/bin/env bash
#
# Spinner progress indicator.
#
# Dependencies: none

# Spinner function
spinner() {
    local pid="$1"
    # Progress bar characters
    chars="/-\|"

    while kill -0 "$pid" 2>/dev/null; do
        for ((i = 0; i < ${#chars}; i++)); do
            echo -ne "${chars:$i:1}" "\r"
            sleep 0.1 # Adjust sleep duration to control the speed of the spinner
        done
    done
    echo -ne "Process completed.\n"
}

# Start your process in the background and get its PID
your_command & # Replace 'your_command' with your actual command
pid=$!

echo -n "Processing "
# Start the spinner
spinner "$pid"
