#!/usr/bin/env bash
#
# Check if provided arguments are valid shell commands.
#
# Dependencies: none

_GeneralCmdCheck() {
    # Iterate through the provided arguments
    for cmd in "$@"; do
        command -v "$cmd" &>/dev/null || {
            echo "Error: '$cmd' is not a valid command." >&2
            echo "Exiting"
            exit 1
        }
    done
}

_GeneralCmdCheck "$@"
