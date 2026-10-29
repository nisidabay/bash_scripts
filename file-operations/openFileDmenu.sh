#!/usr/bin/env bash
#
# Open file with dmenu.
#
# Dependencies: dmenu, find, xdg-open

CURRENT_DIR=$(pwd)
CHOSEN_FILE=$(find "$CURRENT_DIR" -type f | dmenu -l 20 -p "Choose a file:")

if [ -n "$CHOSEN_FILE" ]; then
    xdg-open "$CHOSEN_FILE" || echo "Error opening file: $CHOSEN_FILE"
fi
