#!/usr/bin/env bash
#
# Show Spotify playback status.
#
# Dependencies: spotify/spotifyd, playerctl

dwm_spotify() {
    if ps -C spotify >/dev/null; then
        PLAYER="spotify"
    elif ps -C spotifyd >/dev/null; then
        PLAYER="spotifyd"
    fi

    if [ "$PLAYER" = "spotify" ] || [ "$PLAYER" = "spotifyd" ]; then
        ARTIST=$(playerctl metadata artist)
        TRACK=$(playerctl metadata title)
        POSITION=$(playerctl position | sed 's/..\{6\}$//')
        DURATION=$(playerctl metadata mpris:length | sed 's/.\{6\}$//')
        STATUS=$(playerctl status)
        SHUFFLE=$(playerctl shuffle)

        if [ "$IDENTIFIER" = "unicode" ]; then
            if [ "$STATUS" = "Playing" ]; then
                STATUS="▶"
            else
                STATUS="⏸"
            fi

            if [ "$SHUFFLE" = "On" ]; then
                SHUFFLE=" 🔀"
            else
                SHUFFLE=""
            fi
        else
            if [ "$STATUS" = "Playing" ]; then
                STATUS="PLA"
            else
                STATUS="PAU"
            fi

            if [ "$SHUFFLE" = "On" ]; then
                SHUFFLE=" S"
            else
                SHUFFLE=""
            fi
        fi

        if [ "$PLAYER" = "spotify" ]; then
            printf "%s%s %s - %s " "$SEP1" "$STATUS" "$ARTIST" "$TRACK"
            printf "%0d:%02d" $((DURATION % 3600 / 60)) $((DURATION % 60))
            printf "%s\n" "$SEP2"
        else
            printf "%s%s %s - %s " "$SEP1" "$STATUS" "$ARTIST" "$TRACK"
            printf "%0d:%02d/" $((POSITION % 3600 / 60)) $((POSITION % 60))
            printf "%0d:%02d" $((DURATION % 3600 / 60)) $((DURATION % 60))
            printf "%s%s\n" "$SHUFFLE" "$SEP2"
        fi
    fi
}

dwm_spotify
