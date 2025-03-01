#!/usr/bin/bash
#
# Checks that an internet connection exists.
#
# Function to check and install a package
check_and_install() {
    local package=$1
    if ! pacman -Qi "$package" &>/dev/null; then
        echo "$package is not installed. Installing..."
        sudo pacman -S "$package"
    fi
}

# Check for necessary packages
check_and_install curl

function main() {
    local default=https://duckduckgo.com

    /usr/bin/curl --silent --fail --connect-timeout 8 "$default" >/dev/null
    status="$?"
    if [ $status -eq 0 ]; then
        echo "Internet is ON"
    else
        echo "Internet is OFF"
    fi
}

main
