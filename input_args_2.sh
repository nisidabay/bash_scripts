#!/usr/bin/bash
##################################################
# Name: input_args_2.sh
#
# Purpose: Parse input arguments using case
#
# Author:
#
# Date: dom 13 jun 2021 05:59:35 CEST
#
# Code from: https://www.golinuxcloud.com
#
# Modified by:
## On Date:
#
# It doesn't handle missing values for args
#
# [+]
# [-]
################################################## 

function show_usage(){
    printf "Usage: $0 [options [parameters]]\n"
    printf "\n"
    printf "Options:\n"
    printf " -r|--rmp [rpm name], Print rpm name\n"
    printf " -s|--sleep, Provide the valut to sleep\n"
    printf " -h|--help, Print help\n"
    
return 0
}

while [ -n "$1" ];do
    case "$1" in
        -h|--help)
            show_usage
            ;;
        -r|--rpm)
            shift
            RPM_NAME="$1"
            echo "rpm name is $RPM_NAME"
            ;;
        -s|--sleep)
            shift
            SLEEP="$1"
            echo "sleep value is $SLEEP"
            ;;

        *)
            echo "Incorrect input provided"
            show_usage
    esac
    shift
done
