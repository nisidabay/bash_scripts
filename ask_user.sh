#!/bin/bash
# 
# Ask user for an action
ask_user(){
    read -p "Do you want to see the log file? (y/N) " answer
    case "$answer" in
        [yY]*)
            clear
            # Perform some action
            ;;
        [nN]*)
            return;;
        *)
            return;;
        esac
}
ask_user
