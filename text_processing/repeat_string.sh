#!/usr/bin/env bash
#
# Print a string a number of times.
#
# Dependencies: printf

function repeatString() {
    local -r string="${1}"
    local -r numberToRepeat="${2}"
    if [[ "${string}" != '' && "${numberToRepeat}" =~ ^[1-9][0-9]*$ ]]; then
        local -r result="$(printf "%${numberToRepeat}s")"
        echo -e "${result// /${string}}"
    fi
}

repeatString carlos 35
