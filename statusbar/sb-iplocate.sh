#!/usr/bin/env bash
#
# Display public IP and country flag for dwmblocks.
#
# Dependencies: curl, geoiplookup
# Environment: $XDG_DATA_HOME, $HOME

# Ensure the required commands are available
command -v curl >/dev/null 2>&1 || {
    echo "curl is required but not installed. Aborting."
    exit 1
}
command -v geoiplookup >/dev/null 2>&1 || {
    echo "geoiplookup is required but not installed. Aborting."
    exit 1
}

# Retrieve the public IP address
addr="$(curl -s ifconfig.me)" || {
    echo "Failed to retrieve IP address. Aborting."
    exit 1
}

# Perform geolocation lookup
geoip_info=$(geoiplookup "$addr") || {
    echo "Failed to perform geolocation lookup. Aborting."
    exit 1
}

# Extract the country code from the geolocation info
country_code=$(echo "$geoip_info" | sed -n 's/.*: \([A-Z]\{2\}\).*/\1/p')

# Display the flag emoji corresponding to the country code
flag=$(grep "flag: " "${XDG_DATA_HOME:-$HOME/.local/share}/bin/dmenu/emoji_list" | grep "$country_code" | sed "s/flag: //;s/;.*//")

# Check if flag emoji was found
if [ -n "$flag" ]; then
    echo "Your public IP address: $addr"
    echo "You are located in: $geoip_info"
    echo "Country flag: $flag"
else
    echo "Flag emoji for country code '$country_code' not found."
fi
