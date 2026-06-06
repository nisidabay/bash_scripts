#!/usr/bin/env bash
#
# Update system packages with sudo.
#
# Dependencies: apt-get

request_sudo() {
    echo "Please enter your sudo password to perform privileged tasks."
    if ! sudo -v; then
        echo "Failed to obtain sudo privileges. Exiting."
        exit 1
    fi

    # Keep sudo timestamp updated while the script is running
    while true; do
        sudo -v
        sleep 60
    done 2>/dev/null &
    # Capture the PID of the background job
    local keep_alive_pid=$!
    echo "Keeping sudo session alive..."

    # Trap script exit and ensure the background job is terminated
    trap 'kill ${keep_alive_pid}; exit' EXIT

    # Actual script commands requiring sudo
    echo "Updating system packages..."
    sudo apt-get update

    echo "Upgrading system packages..."
    sudo apt-get upgrade -y

    echo "Cleaning up package cache..."
    sudo apt-get autoremove -y
    sudo apt-get autoclean

    echo "Script execution completed."
}

request_sudo
