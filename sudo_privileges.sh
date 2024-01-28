#!/usr/bin/bash
#
# Request sudo password 
echo "Please enter your sudo password to perform privilege tasks."
sudo -v
if [ "$?" -ne 0 ]; then
    echo "Failed to obtain sudo privileges. Exiting."
    exit 1
fi
