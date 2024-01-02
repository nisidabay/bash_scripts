#!/usr/bin/bash
# 
# Show a status indicator

show_duplicates(){
md5sum *.$1 | awk '{counts[$1]++; names[$1]=names[$1] " " $2} END {for (key in counts) print counts[key] " " key ":"  names[key]}' | grep -v '^1 ' \
    | sort -nr
    }
function status_indicator(){
    read -rp ">>> Enter the file extension without period: " ext
    show_duplicates "$ext"

    pid=$!

    frames="/ | \ -"

    #"Check that the process is still running
    while kill -0 $pid > /dev/null;
    do
        for frame in $frames;
        do
            printf "\r$frame %s", "Loading..."
            sleep 0.5
        done
    done
    printf "\n"
}
status_indicator
