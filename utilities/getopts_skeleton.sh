#!/usr/bin/env bash
#
# Skeleton demonstrating getopts usage.
#
# Dependencies: none

expand_bg="\e[K"
blue_bg="\e[0;104m${expand_bg}"
red_bg="\e[0;101m${expand_bg}"
green_bg="\e[0;42m${expand_bg}"
bold="\e[1m"
uline="\e[4m"

red_bg="\e[0;101m${expand_bg}"
green="\e[0;32m\033[1m"
red="\e[0;31m\033[1m"
blue="\e[0;34m\033[1m"
yellow="\e[0;33m\033[1m"
purple="\e[0;35m\033[1m"
turquoise="\e[0;36m\033[1m"
gray="\e[0;37m\033[1m"
reset="\033[0m\e[0m"
# Basic usage

function show_help() {

    echo -e "${turquoise}Usage: $0 -u user -p password -h [show_help]${reset}"
    echo -e "${green}Prompt for a user and a password${reset}"
    echo -e "${green}   -u User name on the system${reset}"
    echo -e "${green}   -p User's password${reset}"
    echo -e "${green}   -h Show this message and exit${reset}"
}

function _Processin_args() {
    echo -e "${blue}Choose option: $user${reset}"
    echo -e "${blue}Choose option: $pass${reset}"
    exit 0
}

opt_counter=0
while getopts :hu:p: option; do
    case $option in
    u)
        user=$OPTARG
        let opt_counter+=1
        ;;

    p)
        pass=$OPTARG
        let opt_counter+=1
        ;;

    h) show_help ;;

    \?)
        echo -e "${red}[-] Invalid option: -${OPTARG}${reset}"
        show_help
        exit 1
        ;;

    :)
        echo -e "${red}[-] Missing value for the argument: -${OPTARG}${reset}"
        show_help
        exit 1
        ;;
    esac
done
shift $((OPTIND - 1))

[ $opt_counter -eq 0 ] && show_help && exit 1

_Processin_args
