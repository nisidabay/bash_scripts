#!/usr/bin/bash
#
# Check if the file exists
#
# Arguments:
#   None
#
# Returns:
#   None
# 
# Author: nisidabay
red=$(tput setaf 1)
reset=$(tput sgr0)
function chk_file(){
	tput civis
    file="$1"
    if [ ! -f "$file"  ]; then
        echo "${red}[!]${reset} [$file] ${red}does not exist${reset}"
    fi
    echo
    tput cnorm
}
#--- test
chk_file "$1"
