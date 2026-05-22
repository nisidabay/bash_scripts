#!/usr/bin/env bash
#
# Check if a file exists.
#
# Dependencies: tput

red=$(tput setaf 1)
reset=$(tput sgr0)

function chk_file() {
    tput civis
    file="$1"
    if [ ! -f "$file" ]; then
        echo "${red}[!]${reset} [$file] ${red}does not exist${reset}"
    fi
    echo
    tput cnorm
}

chk_file "$1"
