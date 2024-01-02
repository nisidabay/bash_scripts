#!/usr/bin/bash
###############################################################################
# Author: Carlos Lacaci Moya
# Description: Shows the name of the running distro
# Date: dom 05 dic 2021 05:43:41 CET
# Dependencies:
############################################################################### 
set -euo pipefail

test -e /etc/os-release && os_release='/etc/os-release' || os_release='/usr/lib/os-release'

# Stores the output as env variables during script execution
. "${os_release}"

OS=${ID,,}  # Name in lowercase
case $OS in
    *debian*)
        echo "Running on debian"
        ;;
    *ubuntu*)
        echo "Running on ubuntu"
        ;;
    *manjaro*)
        echo "Running on manjaro"
        ;;
    *fedora*)
        echo "Running on fedora"
        ;;
    *endeavouros*)
        echo "Running on endeavouros"
        ;;
    *)
        echo "Unknown linux distro"
        ;;
esac



