#!/usr/bin/env bash
#
# Check network connectivity.
#
# Dependencies: nslookup, awk

function check_network() {
    # Check connectivity

    eth=$(nslookup $(hostname) | awk -F ":" '$1 == "Address", $2 ~ /([0-9]+\.){3}/ { print }')
    echo -e "eth: $eth"

    if [[ -z $eth ]]; then
        echo -e "${gray}${red_bg}[-] Network is down!${reset}"
        exit 1
    else
        echo "UP"
    fi
}

check_network
