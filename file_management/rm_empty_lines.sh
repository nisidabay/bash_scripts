#!/usr/bin/bash
#
# Remove empty lines from a file and makes a backup copy
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
function rm_empty_lines(){
    file="$1"
    if [[ -e "$file" && -f "$file" ]]; then
        sed -i.bak '/^\s*$/d' "$file"
    else
        echo "${red}[!]${reset} [$file] ${red}does not exist or is not a regular file${reset}"
    fi
}
#--- test
rm_empty_lines "$1"
