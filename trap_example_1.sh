#!/usr/bin/bash
##################################################
# Name: trap_example-1.sh
#
# Purpose: Understand the signals
#
# Author: Clm
#
# Date: dom 06 jun 2021 04:55:33 CEST
#
# Code from:
#
# Modified by: Clm
## On Date 
# Date: dom 06 jun 2021 04:56:01 CEST
#
# Actions taken:
#
# [+] Added SIGKILL
################################################## 

function cleanup() {
# Clean txt files in CWD
    echo
    echo " Script killed."
	echo " Cleaning files ..."
	find . -maxdepth 1 -type f  -name "*.txt" -delete
	exit 0
}

# Call when kill PID
trap cleanup SIGTERM

# Call when Ctrl + C
# kill -2
trap cleanup SIGINT

# Call when nothing else work
# kill -9. Cannot be caught
trap cleanup SIGKILL

# Main execution
PROGRAM=$(basename $0)

echo "[$PROGRAM] PID: $$"

for i in $(seq 1 10)
do
	echo "Creating file $i.txt"
	touch $i.txt
	sleep 2
done


