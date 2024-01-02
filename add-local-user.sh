#!/bin/bash
#
# This script creates a new user on the local system.
# You will be prompted to enter the username (login), the person name,
# and a password.
# The username, password, and host for the account will be displayed.

#!/bin/bash

# Check if the script is run as root. Exit if not.
if [[ "${UID}" -ne 0 ]]; then
    echo "Please run with sudo or as root."
    exit 1
fi

# Prompt for the username to create.
read -p -r "Enter the username to create: " USER_NAME

# Check if the user already exists in the system.
if grep -iq "^${USER_NAME}:" /etc/passwd; then
    echo "$USER_NAME exists on the system. Aborting."
    exit 1
fi

# Prompt for the real name (to be used as a description for the user account).
read -p -r "Enter the real name for the user: " REAL_NAME

# Prompt for the password.
read -p -r "Enter the password to use for the account: " PASSWORD

# Create the user account with the given username and real name.
if ! useradd -c "${REAL_NAME}" -m "${USER_NAME}";then
    echo "The account could not be created."
    exit 1
fi

# Set the password for the user.
if ! echo "${PASSWORD}" | passwd --stdin "${USER_NAME}";then
    echo "The password for the account could not be set."
    exit 1
fi


# Force password change on first login.
passwd -e "${USER_NAME}"

# Display the username, password, and host where the account was created.
echo "Account created successfully:"
echo "Username: ${USER_NAME}"
echo "Password: ${PASSWORD}"
echo "Host: ${HOSTNAME}"
exit 0
