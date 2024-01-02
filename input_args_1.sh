#!/usr/bin/bash
##################################################
# Name: input_args_1.sh
#
# Purpose: Parse input arguments with if condition
#          and while loop
# Author:
#
# Date: dom 13 jun 2021 05:59:35 CEST
#
# Code from: https://www.golinuxcloud.com
#
# Modified by:
## On Date:
#
# Actions taken:
#
# [+]
# [-]
################################################## 

function show_usage(){
    printf "Usage: $0 [options [parameters]]\n"
    printf "\n"
    printf "Options:\n"
    printf " -r|--rmp [rpm name], Print rpm name\n"
    printf " -s|--sleep, Provide the value to sleep\n"
    printf " -h|--help, Print help\n"
    
return 0
}

while [ -n "$1" ];do
    if [[ "$1" == "--help" ]] || [[ "$1" == "-h" ]];then
        show_usage
    elif [[ "$1" == "-r" ]] || [[ "$1" == "--rpm" ]];then
        RPM_NAME="$2"
        echo "rpm name is $RPM_NAME"
        shift
    elif [[ "$1" == "-s" ]] || [[ "$1" == "--sleep" ]];then
        SLEEP="$2"
        echo "sleep value is $SLEEP"
        shift
    else
        echo "Incorrect input provided"
        show_usage
    fi
# Avoid infinite loop
shift
done
