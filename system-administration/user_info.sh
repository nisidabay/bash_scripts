#!/usr/bin/env bash
#
# Find user information on the system.
#
# Dependencies: grep, awk
#

findUser() {
    read -p "Enter the user login: " LOGIN

    # Attempt to find the user in /etc/passwd
    if cat /etc/passwd | grep "$LOGIN" >/dev/null; then
        echo "[+] Found user: $LOGIN"
        # Print detailed user information
        cat /etc/passwd | awk -v login="$LOGIN" 'BEGIN{FS=":"} $1 == login {print $1, $5, $6, $7}'
    else
        # For macOS, attempt to find the user using dscl
        if [ "$(uname)" = "Darwin" ] && dscl . -list /Users | grep -q "^$LOGIN\$"; then
            echo "[+] Found user: $LOGIN"
            # On macOS, use dscl to get user information
            echo "User details for $LOGIN:"
            dscl . -read /Users/"$LOGIN" RealName NFSHomeDirectory UserShell
        else
            echo "[-] User not found!"
        fi
    fi
}

# Call the function
findUser
