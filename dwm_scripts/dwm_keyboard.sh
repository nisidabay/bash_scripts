#!/usr/bin/env bash
#
# Display current keyboard layout.
#
# Dependencies: xorg-setxkbmap

dwm_keyboard() {
    printf "%s" "$SEP1"
    if [ "$IDENTIFIER" = "unicode" ]; then
        printf "⌨ %s" "$(setxkbmap -query | awk '/layout/{print $2}')"
    else
        printf "KEY %s" "$(setxkbmap -query | awk '/layout/{print $2}')"
    fi
    printf "%s\n" "$SEP2"
}

dwm_keyboard
