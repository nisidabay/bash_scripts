#!/usr/bin/bash
# Author: Carlos Lacaci Moya
# Description: Send files/folders over SCP to a series of hosts
# This is a small wrapper of "remote_transfer.sh"
# Date: sáb 18 dic 2021 07:40:51 CET
# Dependencies: remote_transfer.sh

# Debugging setup for bash
set -euo pipefail
################################################################################ 
# GLOBAL VARIABLES
################################################################################

# Ansi color code global variables
expand_bg="\e[K"
blue_bg="\e[0;104m${expand_bg}"
red_bg="\e[0;101m${expand_bg}"
green_bg="\e[0;42m${expand_bg}"
green="\e[0;32m\033[1m"
red="\e[0;31m\033[1m"
turquoise="\e[0;36m\033[1m"
gray="\e[0;37m\033[1m"
yellow="\e[1;93m\033[1m"
reset="\033[0m\e[0m"

DEPENDENCIES=(remote_transfer.sh)
OK='✔'
FAIL='✘'
declare -a favorite_hosts
################################################################################

favorite_hosts=(bullseye shredder BlackManjaro.home iMacEndeavourOs.home pop-os-blanco.home FreeBSD)

function check_program_dependencies(){
# Check for necessary binaries

    for prog in "${DEPENDENCIES[@]}"; do
    
        # Check for remote_transfer.sh in HOME
        [[ -f "$HOME/bin/$prog" ]] > /dev/null 2>&1
        if [ $? -ne 0 ];then
            echo -e "\t[-] $prog -> ${red}$FAIL${reset}"
            exit 1
        fi

    done
}

function get_ip_from_name(){
# Get the ip from the favorite_hosts

name=$1
eth=$(nslookup $name | awk -F ":" '$1 == "Address" { print $2 }' | sed -ne '/#/!p')

if [[ -z $eth ]];then
    echo -e "${red}[-] Unknown host!${reset}"
fi

# Return the value
echo $eth
}

function transfer_files(){
# Transfer files to remote hosts

    # This computer
    myself=$(hostname)

    for host in "${favorite_hosts[@]}"; do

        barename=${host%.home}
        # Skip myself from the favorite_hosts
        if [ $barename == $myself ];then
            continue
        fi

        # Get the name of the host
        name=$(get_ip_from_name "$host")

        # Is online?
        value=$(ping -c1 "$name" > /dev/null 2>&1 && echo 0 || echo 1)

        if [[ $value -eq 0 ]];then
            remote_transfer.sh -i "$name" -d "$host_folder" -f "$files" 

        elif [[ $value -eq 1 ]];then
            echo -e "[!] Host [${red}$host${reset}] unreachable ${red}$FAIL${reset}\n"
            echo "On $(date) -> Fail to send to: $host -d $host_folder -f $files" >> transfer2fav.log
            echo "---" >> transfer2fav.log
            continue
        fi
    done
    echo -e "[!] ${turquoise}See 'transfer2fav.log' for details${reset}\n"
}

function show_help(){
# Usage

  echo -ne "${yellow}Transfer files favorite hosts\n${reset}"
  echo
  echo -ne "${gray}Usage: transfer2fav.sh [OPTIONS]\n"
  echo
  echo -ne "\t-d [remote host folder]\n"
  echo -ne "\t-f [file/folder to transfer to]\n${reset}"
  echo
  echo -ne "${red}\tExamples:\n${reset}"
  echo -ne "\ttransfer.sh -d Downloads -f \"movie_1.mkv\"\n"
  echo -ne "\ttransfer.sh -d . -f \"movie_1.mkv\"\n"
  echo -ne "\ttransfer.sh -d Downloads -f \"Movies\"\n"
  echo -ne "\ttransfer.sh -d . -f \"Movies\"\n"

  echo -ne "${yellow}@Carlos Lacaci Moya - 2021 ;)\n${reset}"
  exit 0
}

opt_counter=0
while getopts ":hd:f:" option;do
  case $option in
    d)
        host_folder=$OPTARG;(( opt_counter+=1 ))
        ;;
    f)
        files=$OPTARG;(( opt_counter+=1 ))
        ;;
    h) 
        show_help
        ;;
    \?) 
        echo -e "${red}[-] Invalid option -$OPTARG${reset}"
        show_help
        ;;

    :) 
        echo -e "${red}[-] Missing value for the argument [-$OPTARG]${reset}"
        show_help
        ;;
  esac
done
shift $(( $OPTIND - 1 ))

if [ "$opt_counter" -eq 0 ] || [ "$opt_counter" -ne 2 ];then
    show_help
else
    check_program_dependencies
    transfer_files
fi



