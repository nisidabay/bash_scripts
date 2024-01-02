#!/usr/bin/bash
###############################################################################
# Name: select-menu.sh
# Purpose: Throw away menu 
#
# Author: Carlos Lacaci Moya  
# Date: sáb 04 sep 2021 16:57:48 CEST
#
# Modified by: 
# Date: 
#
# Actions taken:
#
###############################################################################
# Ansi color code global variables
expand_bg="\e[K"
blue_bg="\e[0;104m${expand_bg}"

turquoise="\e[0;36m\033[1m"
gray="\e[0;37m\033[1m"
reset="\033[0m\e[0m"
################################################################################

function banner(){
    echo -e "${gray}${blue_bg}Menu - Select option${reset}"
}

export PS3="-> "

clear
banner

select CHOICE in option_1 option_2 option_3
do
    banner
    case $CHOICE in

        option_1) echo -e "${turquoise}\tcommand 1${reset}";;
        option_2) echo -e "${turquoise}\tcommand 2${reset}";;
        option_3) echo -e "${turquoise}\tcommand 3${reset}";;
        *) exit;;

    esac

done
