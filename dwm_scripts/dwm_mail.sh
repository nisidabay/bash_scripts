#!/usr/bin/env bash
#
# Display inbox email count.
#

dwm_mail() {
    MAILBOX=$(ls /path/to/inbox | wc -l)

    printf "%s" "$SEP1"
    if [ "$IDENTIFIER" = "unicode" ]; then
        if [ "$MAILBOX" -eq 0 ]; then
            printf "📪 %s" "$MAILBOX"
        else
            printf "📫 %s" "$MAILBOX"
        fi
    else
        printf "MAI %s" "$MAILBOX"
    fi
    printf "%s\n" "$SEP2"
}

dwm_mail
