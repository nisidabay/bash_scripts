#!/usr/bin/bash
#
# Checks that an internet connection exists.
#

function Main() {
    local default=https://duckduckgo.com

    /usr/bin/curl --silent --fail --connect-timeout 8 "$default" >/dev/null

    if [  $? -eq 0 ];then
        echo "Internet is ON"
    else
        echo "Internet is OFF"
    fi 
}

Main 
