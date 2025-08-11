#!/usr/bin/bash
##################################################
# Name: genpasswd.sh
#
# Purpose: Generate random passwords
#
# Date: vie 11 jun 2021 16:34:08 CEST
#
# Author: From introduction to Advanced Bash Usage
# James Pannacciulli
#
# Modified by: clm
# Date: mié 25 ago 2021 17:29:59 CEST
##################################################

# Ansi color code global variables
red="\e[0;91m"
blue="\e[0;94m"
green="\e[0;32m"
yellow="\e[0;33m"
bold="\e[1m"
reset="\e[0m"

# Globals
PASSWD_LBL=9

function separator(){
    # Add fancy separator
    for ((i=0; i<= $((${#PASSWD}+$PASSWD_LBL)); i++));do
        echo -n -e "${red}-${reset}"
    done
    echo 
} 

function show_help(){
  # Usage
  printf "${green}Generate a random password.\n${reset}"
  printf "length [-l ] must be 8 or more characters\n"
  printf "${green}\tusage: $0 -l [length] [-s] [save_to_file] [-p] [persistent]\n${reset}"
  printf "${green}\t -l [length]: length of the password\n${reset}"
  printf "${green}\t -s [save_to_file]: name of the password to store\n${reset}"
  printf "${green}\t -p [persistent]: make the file undeleteable\n${reset}"
  echo
  printf "${green}Example: $0 -l 8 -s dropbox\n${reset}"
  printf "${green}Example: $0 -l 12 -s amazon_password -p yes\n${reset}"
  exit 1
}

function genpass(){
    # Main function
    # Check for valid parameter
    if [ ${#length} -ge 1 ] && [ $length -gt 7 ];then

        PASSWD=$(tr -dc 'a-zA-Z0-9_#@.-' < /dev/urandom | head -c ${1:-$length} | tee ${out_file})

        separator
        echo -e "${green}${bold}Password: $PASSWD ${reset}"
        outfile_separator
    else
        echo -e "${red}[-] Invalid option - $OPTARG or password length less than 8 characters${reset}"
        show_help
        exit 1
    fi
}

function outfile_separator(){
    # Add separator to password name
    if [[ $out_file != "" ]];then
        echo -e "${blue}${bold}Name: $out_file${reset}"
        separator
    fi
}

function make_persistent(){
    # Make the password file inmutable
    if [ "$persistent" == "yes" ];then
        new_file="$(pwd)/$out_file"
        if [ -f "$new_file" ];then
            # Check for inmutability set already
            inmu_set=$(lsattr $new_file | sed -n '/-i/p' | wc -l)
            if [[ $inmu_set -eq 1 ]]; then
                clear
                echo -e "${red}${bold}[-]Aborting. The password ${green}${bol}$out_file${rese}${red}${bold} is already set and is inmutable${reset}"
                separator
                echo $new_file
                echo -n "Password: ";cat $new_file
                echo
                separator
                exit 1
            fi
                
            $(sudo chattr +i $new_file)
            echo -e "${yellow}${bold}Inmutable: yes${reset}"
            separator
        fi
    fi
}


# Exit if no args provided
[[ $# -eq 0 ]] && show_help
while getopts ":hl:s:p:" option;do
  case $option in
    l) 
        length=$OPTARG
        ;;
    s) 
        save=$OPTARG
        out_file=$save
        ;;
    p)
        persistent=$OPTARG
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
shift $(($OPTIND - 1))

# Entry point
genpass
make_persistent
