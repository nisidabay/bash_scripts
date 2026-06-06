#!/usr/bin/env bash
#
# Create a new local user account.
#
# Dependencies: useradd, chpasswd, passwd

createUserAccount() {
    # Check if the script is run as root. Exit if not within the function.
    if [[ "${UID}" -ne 0 ]]; then
        echo "Please run with sudo or as root."
        return 1
    fi

    # Prompt for the username to create.
    read -rp "Enter the username to create: " USER_NAME

    # Check if the user already exists in the system.
    if grep -iq "^${USER_NAME}:" /etc/passwd; then
        echo "$USER_NAME exists on the system. Aborting."
        return 1
    fi

    # Prompt for the real name (to be used as a description for the user account).
    read -rp "Enter the real name for the user: " REAL_NAME

    # Prompt for the password.
    read -rp "Enter the password to use for the account: " PASSWORD

    # Create the user account with the given username and real name.
    if ! useradd -c "${REAL_NAME}" -m "${USER_NAME}"; then
        echo "The account could not be created."
        return 1
    fi

    # Set the password for the user.
    echo "${USER_NAME}:${PASSWORD}" | chpasswd

    if [ $? -ne 0 ]; then
        echo "The password for the account could not be set."
        return 1
    fi

    # Force password change on first login.
    passwd -e "${USER_NAME}"

    # Display the username, password, and host where the account was created.
    echo "Account created successfully:"
    echo "Username: ${USER_NAME}"
    echo "Password: ${PASSWORD}"
    echo "Host: $(hostname)"
    return 0
}

# Example of how to call the function
createUserAccount
