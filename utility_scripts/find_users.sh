#!/bin/sh
# 
# Check if user exists

CheckUser() {
    local user="$1"

    # Determine the operating system
    local os=$(uname)

    # For Linux systems
    if [ "$os" = "Linux" ]; then
        if grep -q "^$user:" /etc/passwd; then
            return 0  # User exists
        else
            return 1  # User does not exist
        fi
    # For macOS systems
    elif [ "$os" = "Darwin" ]; then
        if dscl . -list /Users | grep -q "^$user\$"; then
            return 0  # User exists
        else
            return 1  # User does not exist
        fi
    else
        echo "Unsupported operating system."
        return 2  # Unsupported OS
    fi
}

# Example usage of the function
user="nisidabay"  # Replace this with the username you want to check

if ! CheckUser "$user"; then 
    echo "The user does not exist."
else
    echo "The user exists."
fi
