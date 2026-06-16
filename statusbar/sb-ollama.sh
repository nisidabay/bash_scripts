#!/usr/bin/env bash
#
# Run AI chat from dwmblocks.
#
# Dependencies: notify-send
# Environment: $TERMINAL, $EDITOR

TERMINAL="st"
script=~/bin/lola.sh

# Set the icon
icon="🤖"

# Display icon
echo "$icon"

# Handle different mouse button clicks
case "$BLOCK_BUTTON" in
1)
    # Left-click: Launch the terminal detached from dwmblocks
    setsid -f "$TERMINAL" -e sh -c "$script"
    ;;
2 | 3)
    # Middle/Right-click: Explain what the script does
    notify-send "🤖 AI Robot" "Left-click: Run the AI chat\nRight/Middle-click: Show this help"
    ;;
esac
