#!/usr/bin/env bash
#
# Show cmus playback status.
#
# Dependencies: cmus
# Environment: $TERMINAL, $EDITOR

dwm_cmus() {
    SEP1="|"
    if ps -C cmus >/dev/null; then
        CMUSDATA=$(cmus-remote -Q)
        ARTIST=$(echo "$CMUSDATA" | grep -w '^tag artist' | awk '{gsub("tag artist ", "");print}')
        TRACK=$(echo "$CMUSDATA" | grep -w '^tag title' | awk '{gsub("tag title ", "");print}')
        POSITION=$(echo "$CMUSDATA" | grep -w '^position' | awk '{gsub("position ", "");print}')
        DURATION=$(echo "$CMUSDATA" | grep -w '^duration' | awk '{gsub("duration ", "");print}')
        STATUS=$(echo "$CMUSDATA" | grep -w '^status' | awk '{gsub("status ", "");print}')
        SHUFFLE=$(echo "$CMUSDATA" | grep -w '^set shuffle' | awk '{gsub("set shuffle ", "");print}')

        if [ "$STATUS" = "playing" ]; then
            STATUS="▶"
        else
            STATUS="⏸"
        fi

        if [ "$SHUFFLE" = "true" ]; then
            SHUFFLE=" 🔀"
        else
            SHUFFLE=""
        fi

        printf "%s%s %s - %s " "$SEP1" "$STATUS" "$ARTIST" "$TRACK"
        printf "%0d:%02d/" $((POSITION % 3600 / 60)) $((POSITION % 60))
        printf "%0d:%02d" $((DURATION % 3600 / 60)) $((DURATION % 60))
        printf "%s%s\n" "$SHUFFLE" "$SEP1"
    fi
}

dwm_cmus
