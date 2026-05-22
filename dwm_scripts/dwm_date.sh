#!/usr/bin/env bash
#
# Show current date and time.
#

dwm_date() {
    printf "%s" "$SEP1"
    if [ "$IDENTIFIER" = "" ]; then
        printf "📆 %s" "$(date "+%a %d-%m-%y %T")"
    else
        # printf "DAT %s" "$(date "+%a %d-%m-%y %T")"
        printf "DAT %s" "$(date "+%d-%m-%y %T")"
    fi
    printf "%s\n" "$SEP2"
}

dwm_date
