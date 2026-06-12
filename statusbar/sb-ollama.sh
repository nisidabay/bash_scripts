#!/usr/bin/env bash
#
# Run Ollama from dwmblocks.
#
# Dependencies: ollama, notify-send
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
    notify-send "🤖 Ollama Robot" "Left-click: Run the Ollama chat\nRight/Middle-click: Show this help"
    ;;
esac
