#!/usr/bin/bash
###############################################################################
# Author: Carlos Lacaci Moya
# Description: Change window manager on raspberry
# Date: mar 08 mar 2022 06:01:53 CET
# Dependencies: None
#
# Instructions: 
# Change files autostart and desktop.conf from:
# /etc/xdg/lxsession/LXDE-pi

# In autostart
# To enable i3 comment out Lxpanel, pcmanfm
# To enable Lxpanel uncomment out Lxpanel, pcmanfm 

# In desktop.conf
# To enable i3, change "window_manager=i3"
# To enable lxde, change "window_manager=openbox-lxde-pi"
#
# Version: 1.0
###############################################################################
# Debugging setup for bash
set -euo pipefail

working_directory="/etc/xdg/lxsession/LXDE-pi"


function to_i3(){
    # Change window manager to i3

    cd $working_directory
    sudo sed -i.bk -e 's/@lxpanel/#@lxpanel/' -e 's/@pcman/#@pcman/' autostart
    sudo sed -i.bk '/window_manager/ s/=openbox-lxde-pi/=i3/' desktop.conf
    echo "[+] Window manager changed to i3"

}

function to_lxde(){
    # Change window manager to lxde

    cd $working_directory
    sudo sed -i.bk -e 's/#@lxpanel/@lxpanel/' -e 's/#@pcman/@pcman/' autostart
    sudo sed -i.bk '/window_manager/ s/=i3/=openbox-lxde-pi/' desktop.conf
    echo "[+] Window manager changed to lxde"
}

function show_help(){
    # Show usage

    echo "Change window manager from i3 to lxde and viceversa"
    echo "Usage: raspi_change_wm [-i i3 | -l lxde]"
    exit 0
}

opt_counter=0
while getopts ":hil" option;do
    case $option in
        i)
            to_i3;(( opt_counter+=1 ))
            ;;
        l)
            to_lxde;(( opt_counter+=1 ))
            ;;
        h)
            show_help
            ;;

        \?)
            echo "Invalid option";
            show_help;;
        :)
            show_help;;
    esac
done

if [ "$opt_counter" -eq 0 ] || [ "$opt_counter" -eq 2 ];then
    show_help
fi
