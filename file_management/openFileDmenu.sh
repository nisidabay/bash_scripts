#!/bin/bash
#
# Open file with dmenu

# Get the current directory
CURRENT_DIR=$(pwd)
# Get the list of files in the current directory and pipe it to dmenu
CHOSEN_FILE=$(find "$CURRENT_DIR" -type f | dmenu -l 20 -p "Choose a file:")

# Check if a file was selected and open it
if [ -n "$CHOSEN_FILE" ]; then
  xdg-open "$CHOSEN_FILE" || echo "Error opening file: $CHOSEN_FILE"
fi
