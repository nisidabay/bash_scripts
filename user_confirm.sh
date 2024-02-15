#!/bin/bash
# 
# Quit function. Ask the user for an action

Quit () {
    # Declare local variables for the function
    local prompt default yn

    # Set the prompt and default value based on the first argument ($1)
    case "$1" in
        # If the first argument starts with Y or y, set the prompt to "[Y/n]" and default to Y
        [Yy]*) prompt="[Y/n] "; default=Y;;
        # If the first argument starts with N or n, set the prompt to "[y/N]" and default to N
        [Nn]*) prompt="[y/N] "; default=N;;
        # For any other value, set a neutral prompt "[y/n]" without a default
        *) prompt="[y/n] "; default=;;
    esac

    # Loop indefinitely until the user provides a valid response (Y/y/N/n)
    while true; do
        # Display the prompt to the user without a newline, waiting for input
        printf "%s" "$prompt"
        # Read the user's input into the variable 'yn'
        read -r yn
        # If the user presses Enter without typing anything, use the default value
        if [ -z "$yn" ]; then
            yn=$default
        fi

        # Handle the user's response
        case $yn in
            # If the user responds with Y or y, return success (0) and exit the loop
            [Yy]*) return 0;;
            # If the user responds with N or n, return failure (1) and exit the loop
            [Nn]*) return 1;;
        esac
    done
}

# Example usage of the Quit function
# Test the Quit function with a prompt that defaults to Yes
if Quit "Yes"; then
    # If the user confirms, execute the following command
    echo "Quitting"
fi
