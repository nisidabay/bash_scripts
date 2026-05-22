#!/usr/bin/env bash
#
# Show closest calcurse appointment.
#
# Dependencies: calcurse

dwm_ccurse() {
    APTSFILE="$HOME/.calcurse/apts"
    APPOINTMENT=$(head -n 1 "$APTSFILE" | sed -r 's/\[1\] //')

    if [ "$APPOINTMENT" != "" ]; then
        printf "%s" "$SEP1"
        if [ "$IDENTIFIER" = "unicode" ]; then
            printf "💡 %s" "$APPOINTMENT"
        else
            printf "APT %s" "$APPOINTMENT"
        fi
        printf "%s\n" "$SEP2"
    fi
}

dwm_ccurse
