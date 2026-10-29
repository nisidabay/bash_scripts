#!/usr/bin/env bash
#
# Generate random error log entries.
#
# Dependencies: date

declare -a messages=(
    "Unable to connect to server"
    "File not found"
    "Invalid input"
    "Out of memory"
    "Network error"
)

declare -a alerts=(
    "error"
    "warning"
    "critical"
    "debug"
    "info"
)

function random_log {
    num_messages="$1"
    count=0

    while [ "$count" -lt "$num_messages" ]; do
        error=${messages[$RANDOM % ${#messages[@]}]}
        warnings=${alerts[$RANDOM % ${#alerts[@]}]}
        timestamp=$(date '+%Y-%m-%d %H:%M:%S')
        echo "$timestamp $warnings: $error" >>error.log
        ((count++))
    done
}

random_log "$1"
