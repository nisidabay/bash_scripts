#!/usr/bin/bash
##################################################
# Name: trap_example.sh
# Purpose: Understand the signals
# Author: Clm
# Date: dom 06 jun 2021 04:55:33 CEST
################################################## 

function cleanup() {
    # This function will be called when certain signals are caught.
    # It searches for .txt files in the current directory and deletes them.
    echo
    echo " Script killed."
    echo " Cleaning files ..."
    find . -maxdepth 1 -type f -name "*.txt" -delete
    exit 0
}

# Setup trap for SIGTERM (signal sent to terminate a process).
# This will call the cleanup function when the script receives a SIGTERM.
trap cleanup SIGTERM

# Setup trap for SIGINT (signal sent from a terminal interrupt, typically Ctrl+C).
# This will call the cleanup function when the script receives a SIGINT.
trap cleanup SIGINT

# Attempt to setup trap for SIGKILL.
# IMPORTANT: This will not work because SIGKILL cannot be trapped or ignored.
# The system does not allow a process to catch or ignore SIGKILL.
# trap cleanup SIGKILL

# Main execution
PROGRAM=$(basename "$0")

echo "[$PROGRAM] PID: $$"

# Loop to create text files named 1.txt, 2.txt, ..., 10.txt, pausing for 2 seconds between each.
for i in $(seq 1 10)
do
    echo "Creating file $i.txt"
    touch "$i".txt
    sleep 2
done
