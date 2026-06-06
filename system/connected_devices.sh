#!/usr/bin/env bash
#
# Find connected devices on the local network.
#
# Dependencies: ping

trap ctrl_c INT

function ctrl_c() {
    tput setaf 1 # red color
    echo [!] Exiting from "$BASH_SOURCE" ...
    tput sgr0 # reset color
    exit 1
}
connected() {
    if ping -c 1 "$1" &>/dev/null; then
        echo "[+] Device connected with ip: $1"
    fi
}

for i in 192.168.0.{1..255}; do
    echo "Pinging ip: $i"
    connected "$i"
done
