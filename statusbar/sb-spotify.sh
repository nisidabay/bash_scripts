#!/usr/bin/env bash
#
# Display Spotify song info for dwmblocks.
#
# Dependencies: playerctl, notify-send
# Environment: $TERMINAL
if ! command -v playerctl &>/dev/null; then
    echo "Error: 'playerctl' is not installed. Please install it to use this script."
    exit 1
fi

# Function to fetch and display the current song info
get_song_info() {
    if playerctl --player=spotify status >/dev/null 2>&1; then
        # Fetch artist and title metadata
        local artist=$(playerctl --player=spotify metadata artist)
        local title=$(playerctl --player=spotify metadata title)

        # Truncate long titles for better readability
        local max_length=30
        if [ ${#title} -gt $max_length ]; then
            title="${title:0:$max_length}..."
        fi

        # Display formatted song info
        notify-send "Now Playing" "🎵 $artist - $title" --icon=audio-x-generic
    else
        notify-send -u critical "Warning" "Spotify is not running" --icon=dialog-warning
    fi
}

# Handle button actions (if applicable)
case $BLOCK_BUTTON in
1) setsid -f "$TERMINAL" -e spotify & ;;
3) get_song_info ;;
esac
echo "🎵"
