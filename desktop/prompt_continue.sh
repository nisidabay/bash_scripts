#!/usr/bin/env bash
#
# Prompt to continue inside a loop.
#
# Dependencies: none
#

_continue() {
    # Add default value
    read -r -p "Continue to next track? [Y/n] " ANSWER
    ANSWER=${ANSWER:-Y}
    if [[ ! $ANSWER =~ ^[Yy].* ]]; then
        exit 0
    fi
}
