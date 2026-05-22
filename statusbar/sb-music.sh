#!/usr/bin/env bash
#
# Display music status for dwmblocks.
#
# Dependencies: cmus, notify-send
# Environment: $TERMINAL

icon="🎵"
echo "$icon"

case $BLOCK_BUTTON in
1)
    "$TERMINAL" -e cmus
    icon="🎵"
    ;;
2) pgrep cmus | xargs kill ;;
3) notify-send "🎵 Music module" "\- Shows cmus song playing.
- Left click opens musikcube.
- Middle click stop it." ;;
esac

echo "$icon"
