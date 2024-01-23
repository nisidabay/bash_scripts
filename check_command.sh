#!/usr/bin/bash
check_command() {
    if ! command -v "$1" &> /dev/null; then
        echo "$1 could not be found, please install it first."
        exit 1
    fi
}
# Usage
check_command sxiv
check_command convert
