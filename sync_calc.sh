#!/usr/bin/bash
# Sync calendars
echo "Syncronized calendars"
echo "Blanco [20] - Manjaro [38] - iMac [77]"
read -p "Enter the last ip octet to transfer to: " ip
cd ~/.local/share/calcurse
scp -r * nisidabay@192.168.1.${ip}:~/.local/share/calcurse
