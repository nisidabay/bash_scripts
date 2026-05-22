#!/usr/bin/env bash
#
# Display public IP address and geo-location for dwmblocks.
#
# Dependencies: curl, geoiplookup, notify-send
# Environment: $TERMINAL, $EDITOR

# Ensure the required commands are available
command -v curl >/dev/null 2>&1 || {
    echo "curl is required but not installed. Aborting."
    exit 1
}

command -v geoiplookup >/dev/null 2>&1 || {
    echo "geoiplookup is required but not installed. Aborting."
    exit 1
}

# Function to retrieve the public IPv4 address
get_public_ipv4() {
    public_ip=$(curl -s4 ifconfig.me) || {
        notify-send "Failed to retrieve public IPv4 address." "Please check your internet connection."
        exit 1
    }
    echo "$public_ip"
}

# Function to display IP information in a notification
notify_ip_info() {
    # Retrieve public IPv4 address
    addr=$(get_public_ipv4)

    # Perform geolocation lookup
    geoip_info=$(geoiplookup "$addr") || {
        notify-send "Failed to perform geolocation lookup." "Aborting."
        exit 1
    }

    # Extract country code
    country_code=$(echo "$geoip_info" | sed -n 's/.*: \([A-Z]\{2\}\).*/\1/p')

    if [ -z "$country_code" ]; then
        notify-send "Geolocation failed" "Unable to determine country code."
        exit 1
    fi

    # Map country code to full country name
    case "$country_code" in
    ES) country_name="Spain" ;;
    US) country_name="United States" ;;
    FR) country_name="France" ;;
    DE) country_name="Germany" ;;
    *) country_name="$country_code" ;; # Default to country code if unknown
    esac

    # Look up flag emoji
    flag_file="$HOME/bin/dmenu/emoji_list"
    if [ -f "$flag_file" ]; then
        flag=$(grep "flag: " "$flag_file" | grep "$country_name" | sed "s/flag: //;s/;.*//")
    else
        flag=""
    fi

    # Display notification with flag (if found)
    if [ -n "$flag" ]; then
        notify-send "$flag $addr" "$geoip_info"
    else
        notify-send "$addr" "$geoip_info"
    fi
}

# Function to output public IPv4 information for the status bar
myip() {
    public_ip=$(get_public_ipv4)
    echo "$public_ip"
}

# Handle mouse button clicks
case $BLOCK_BUTTON in
1)
    # Left click: Display public IPv4 information in a notification
    notify_ip_info
    ;;
3)
    # Right click: Display public IPv4 and country flag
    addr=$(get_public_ipv4)

    geoip_info=$(geoiplookup "$addr") || {
        notify-send "Failed to perform geolocation lookup." "Aborting."
        exit 1
    }

    # Extract country code
    country_code=$(echo "$geoip_info" | sed -n 's/.*: \([A-Z]\{2\}\).*/\1/p')

    # Map country code to full country name
    case "$country_code" in
    ES) country_name="Spain" ;;
    US) country_name="United States" ;;
    FR) country_name="France" ;;
    DE) country_name="Germany" ;;
    *) country_name="$country_code" ;; # Default to country code if unknown
    esac

    # Look up flag emoji
    flag_file="$HOME/bin/dmenu/emoji_list"
    if [ -f "$flag_file" ]; then
        flag=$(grep "flag: " "$flag_file" | grep "$country_name" | sed "s/flag: //;s/;.*//")
    else
        flag=""
    fi

    # Display notification with flag (if found)
    if [ -n "$flag" ]; then
        notify-send "$flag" "Public IPv4: $addr\nLocal IPv4: $(ip a | awk '/inet / && !/127.0.0.1/ {print $2}' | head -n 1)\n$geoip_info"
    else
        notify-send "IP Information" "Public IPv4: $addr\nLocal IPv4: $(ip a | awk '/inet / && !/127.0.0.1/ {print $2}' | head -n 1)\n$geoip_info"
    fi
    ;;
esac

# Output the public IPv4 address for the status bar
myip
