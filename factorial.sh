#!/usr/sbin/bash
function factorial() {
    local n="$1"
    if [ "$n" -eq 0 ]; then
        echo 1
    else
        echo $((n * $(factorial $((n - 1)))))
    fi

}
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <number>"
    exit 1
fi
factorial "$1"
