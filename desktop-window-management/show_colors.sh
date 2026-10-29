#!/usr/bin/env bash
#
# Show available terminal colors.
#
# Dependencies: tput

function show_colors() {
    declare -i color=0
    for i in $(seq 1 50); do
        echo "Color:$color $(tput setaf "$i")"
        ((color += 1))
        sleep 0.5
    done
    tput sgr0
}
#-- test
show_colors
