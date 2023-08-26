#!/bin/bash
#
# _GeneralCmdCheck: Checks if the provided arguments are valid shell commands.
# Args:
#   $@: List of commands to be checked.
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
