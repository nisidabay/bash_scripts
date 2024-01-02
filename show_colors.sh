#!/usr/bin/bash
#
# Shows the 50 colors availables in your system
#
# Arguments:
# None
#
# Returns:
# None
# 
# Author: nisidabay
function show_colors(){
    declare -i color=0
    for i in $(seq 1  50)
    do
        echo "Color:$color $(tput setaf "$i")"
        ((color+=1))
        sleep 0.5
    done
    tput sgr0
}
#-- test
show_colors
