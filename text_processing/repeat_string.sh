#!/usr/bin/bash
#
# Print a string a number of times
function repeatString(){
    local -r string="${1}"
    local -r numberToRepeat="${2}"
    if [[ "${string}" != '' && "${numberToRepeat}" =~ ^[1-9][0-9]*$ ]]
    then
        # print empty number of spaces
        local -r result="$(printf "%${numberToRepeat}s")"
        # replace the spaces with the string
        echo -e "${result// /${string}}"
    fi
}
repeatString carlos 35
