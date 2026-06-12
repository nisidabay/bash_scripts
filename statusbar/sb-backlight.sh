#!/usr/bin/env bash
#
# Display backlight brightness.
#
# Dependencies: xbacklight
# Environment: $TERMINAL, $EDITOR

dwm_backlight() {
    printf "%s☀ %.0f%s\n" "$SEP1" "$(xbacklight)" "$SEP2"
}

dwm_backlight
