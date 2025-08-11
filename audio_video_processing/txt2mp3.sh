#!/usr/bin/bash 
# Author: Carlos Lacaci Moya
# Description: Script para pasar de texto a mp3
# Date: dom 12 dic 2021 15:12:25 CET
# Dependencies: svox-bin-pico, lame, mpg123, aplay
# aplay depends on alsa-utils
# pico2wave depends on libttspico-utils

################################################################################ 
# GLOBAL VARIABLES
################################################################################
# Ansi color code global variables
expand_bg="\e[K"
pink_bg="\e[0;104m${expand_bg}"
red_bg="\e[0;101m${expand_bg}"
green_bg="\e[0;042m${expand_bg}"
green="\e[0;32m\033[1m"
red="\e[0;31m\033[1m"
turquoise="\e[0;36m\033[1m"
gray="\e[0;37m\033[1m"
reset="\033[0m\e[0m"

DEPENDENCIES=(pico2wave lame mpg123 aplay)
OK='✔'
FAIL='✘'
WD=$(pwd)

# Choose desire language for pico2wave
#language=es-ES
#language=en-gb
language=en-US
#language=it-IT
#language=de-DE
################################################################################

function dependencies(){
# Check for necessary binaries

    echo -e "${gray}${pink_bg}[!] Checking dependencies${reset}"
    for prog in "${DEPENDENCIES[@]}"; do
    
        for i in $(seq 50);do
            echo -ne "${green}.${reset}"
            sleep 0.01
        done

        # Is the binary installed?
        [[ -f "/usr/bin/$prog" ]] > /dev/null 2>&1
        if [ $? -ne 0 ];then
            echo -e "\t[-] $prog -> ${red}$FAIL${reset}"
            exit 1
        else
            echo -e "\t[+] $prog -> ${green}$OK${reset}"
        fi
    done;sleep 1;clear
}

trap cleanup SIGINT SIGTERM 
function cleanup(){
# Remove temporary file on aborting
    if [ -e "${noext}.wav" ]; then
        rm "${noext}.wav" > /dev/null 2>&1
    fi
}

function run(){
# Main function
    file_path="${WD}/${file}"
	if [[ -f $file_path ]]
	then
		# Text to read
		text=$(cat "$file_path") 
        
		# Remove extesion
		noext=${file_path/.txt/}	

		# Text to wav
        wav=$(pico2wave -l=$language -w="${noext}.wav" "$text" >/dev/null)
        $wav
		# Uncomment to play the wav file
		#aplay ./${noext}.wav

		# Convert to mp3
        lame --quiet "${noext}".wav "${noext}".mp3 > /dev/null 2>&1

        if [[ $? -eq 0 ]];then 
            echo -e "${gray}${pink_bg}[+] File converted to [${noext}.mp3]${reset}"
        else
            echo -e "${gray}{$red_bg}[!] Conversion failed!${reset}"
        fi

		# Uncomment to play the mp3 file created
		#mpg123 -q ${noext}.mp3
    else 
        echo -e "${gray}${red_bg}[!] Missing argument or file does not exist!${reset}"
        show_help
	fi
}	

function delete_file(){
    # Ask for deletion
    tput setaf 196 # Red color
    read -p "[!] Keep the file wav file (y/N)?"
    tput reset

    case $REPLY in
        Y|y)
            return;;
        N|n)
            cleanup;;
        "")
            cleanup;;
        *)
            prompt_again;;
    esac
}
function prompt_again(){
# Invalid option
    clear
    delete_file
}

function show_help(){

# Usage
  echo -ne "${gray}${pink_bg}Convert text to mp3\n${reset}"
  echo
  echo -ne "${green}\tUsage: txt2mp3 -f txt_file\n${reset}"
  echo
  echo -ne "${gray}${pink_bg}@Carlos Lacaci Moya - 2021 ;)\n${reset}"
  exit 0
}

opt_counter=0
while getopts ":hf:" option;do
  case $option in
    f)
        file=($OPTARG);(( opt_counter+=1 ))
        ;;
    h) 
        show_help
        ;;
    \?) 
        echo -e "${gray}${red_bg}[-] Invalid option -$OPTARG${reset}"
        show_help
        ;;

    :) 
        echo -e "${gray}${red_bg}[-] Missing value for the argument [-$OPTARG]${reset}"
        show_help
        ;;
  esac
done
shift $(( $OPTIND - 1 ))

if [[ "$opt_counter" -eq 1 ]];then
    dependencies
    # Star timing
    START="$(date +%s)"
    echo -ne "${gray}${pink_bg}[!] Converting, please wait.\n${reset}"
    # Run the script
    run  2> /dev/null
    # End timing
    END="$(date +%s)"
    DURATION=$[ ${END} - ${START} ]
    # Show timing
    echo -e "${gray}${pink_bg}[+] Program took: $DURATION secs.\n${reset}"
    # Prompt for wav deletion
    delete_file
else
    show_help
fi
