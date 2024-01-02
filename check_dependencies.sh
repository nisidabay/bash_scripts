#!/usr/bin/bash
#
# Checks if the programs passed as strings are installed

# Colors
cyan=$(tput setaf 12)
purple=$(tput setaf 13)
reset=$(tput sgr0)


alert(){
# Show alert message 
tput civis
printf "${purple}✘ %s${reset}\n" "$*"
tput cnorm
}

message(){
# Show message
tput civis
printf "${cyan}✔  %s${reset}\n" "$*"
tput cnorm
}

chk_dependencies(){
# This  checks if the programs passed as strings are installed
tput civis
local -a dependencies_array=("$@")
local -a missing=()

for program in "${dependencies_array[@]}"; do
    if [[ "$(command -v "$program")" ]]; then
        message "Dependency satisfied: $program"
    else
        missing+=("$program")
    fi
done

if [[ "${#missing[@]}" -gt 0 ]]; then
    alert "Install the missing dependencies before continuing:  ${missing[*]}"
    exit 1
fi

tput cnorm
}
