#!/bin/sh
# 
# Ask the user for an action
ask_user_action(){
    # Store the first argument in a local variable for the message prompt
    local msg="$1"
    # Prompt the user with the message and read their answer into the variable 'answer'
    read -p "$msg " answer

    # Analyze the user's answer
    case "$answer" in
        [yY]*)  # If the answer starts with Y or y
            echo "Performing action ..."  # Notify the user about the action
            return 0  # Indicate successful completion
            ;;
        [nN]*)  # If the answer starts with N or n
            # Do nothing specific here
            return 1  # Indicate no action should be taken
            ;;
        *)     # For any other input
            return 2  # Indicate invalid input
            ;;
    esac
}

# Example usage of ask_user function
if ask_user_action "Do you want to see the log file?"; then
    # If the user agrees, perform the action here
    echo "Showing the log file..."
else
    # If the user disagrees or invalid input, handle accordingly
    echo 
fi
