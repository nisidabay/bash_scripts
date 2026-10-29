#!/usr/bin/env bash
#
# Display redshift color temperature for status bar.
#
# Dependencies: redshift, bc
# Environment: $WAYLAND_DISPLAY, $HOME

if pgrep -x "redshift" >/dev/null; then
    temp=$(redshift -p 2>/dev/null | grep -i temp | cut -d ":" -f 2 | tr -dc "[:digit:]")
    lum=$(redshift -p 2>/dev/null | grep -i lum | cut -d ":" -f 2)

    if [[ -z "$temp" ]]; then
        echo "%{F#65737E} OFF "
    elif ((temp >= 5000)); then
        echo "%{F#8FA1B3} $temp K ${lum:+$(echo "100 * $lum" | bc -l)}% "
    elif ((temp >= 4000)); then
        echo "%{F#EBCB8B} $temp K ${lum:+$(echo "100 * $lum" | bc -l)}% "
    else
        echo "%{F#D08770} $temp K ${lum:+$(echo "100 * $lum" | bc -l)}% "
    fi
fi
