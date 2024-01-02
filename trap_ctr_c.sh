#!/usr/bin/bash
#
# Captures the "Ctrl-C" interrupt in a script
#
# Arguments:
#   None
#
# Returns:
#   Exit status 1
# 
# Author: nisidabay

trap ctrl_c INT
function ctrl_c(){
    tput setaf 1 # red color
    echo  [!] Exiting from ["$BASH_SOURCE"] ... 
    tput sgr0
    exit 1
}
#--- test
for i in $(seq 1 100)
do
   tput civis # hide cursor
   echo "$i" 
   sleep 1
done
tput cnorm # reset cursor
