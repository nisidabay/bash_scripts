#!/usr/bin/env bash
#
# Show currency rate against USD.
#
# Dependencies: curl
# Environment: $TERMINAL, $EDITOR

# Change the value of CURRENCY to match your currency code
dwm_currency() {
    CURRENCY=EUR

    printf "%s" "$SEP1"
    if [ "$IDENTIFIER" = "unicode" ]; then
        printf "%s" "$(curl -s rate.sx/1$CURRENCY)"
    else
        printf "%s %.5s" "$CURRENCY" "$(curl -s rate.sx/1$CURRENCY)"
    fi
    printf "%s\n" "$SEP2"
}

dwm_currency
