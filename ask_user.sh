#!/usr/local/bin/bash
# 
# Ask the user for an action
ask_user_action(){
    local msg="$1"  
    local answer  

   # Prompt the user. Default choice is No (N)
    read -p "$msg (y/N): " -sn1 answer
    echo  # Add a newline for better output formatting

    # If no input is provided, treat as 'N'
    if [ -z "$answer" ]; then
        answer="N"
    fi

    # Analyze the user's answer
    case "$answer" in
        [yY])  # If the answer starts with Y or y
            echo "Performing action ..."  # Notify the user about the action
            return 0  # Indicate successful completion
            ;;
        [nN])  # If the answer starts with N or n
            echo "Action canceled."  # Provide feedback for action cancellation
            return 1  # Indicate no action should be taken
            ;;
        *)     # For any other input
            echo "Invalid input."  # Notify the user of invalid input
            return 2  # Indicate invalid input
            ;;
    esac
}

# Example usage of ask_user_action function
if ask_user_action "Do you want to see the log file?"; then
    echo "Showing the log file..."
else
    # This can now be handled more specifically based on the return value if needed
    echo "No action taken."
fi

