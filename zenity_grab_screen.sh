#!/usr/bin/bash

#This will grab the screen waiting a number of seconds before taking the screenshot.

function dependencies(){
    _scrot=$(which scrot)
    if [ ! -f "$_scrot" ];then 
        echo "scrot is not installed!"
        exit 1
    fi
}
dependencies

zAnswer=$(zenity --title "Capture screen" --entry --text "Delay time before capturing the screen in secs." --entry-text "");

if [ ! "$zAnswer" == "" ];then
    scrot -d "$zAnswer"
fi
