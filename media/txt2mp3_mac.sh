#!/usr/bin/env bash
#
# Script para pasar de texto a mp3.
#
# Dependencies: espeak, lame, mpg123
#############################################################################
# GLOBAL VARIABLES
#############################################################################
# Ansi color code global variables
expand_bg="\033[K"
pink_bg="\033[45m${expand_bg}"
red_bg="\033[41m${expand_bg}"
green_bg="\033[46m${expand_bg}"
green="\033[32m"
red="\033[31m\033[1m"
turquoise="\033[36m\033[1m"
gray="\033[37m\033[1m"
reset="\033[0m"

DEPENDENCIES=(espeak lame mpg123)
OK='✔'
FAIL='✘'
WD=$(pwd)

#############################################################################

function dependencies() {
    # Check for necessary binaries

    echo -e "${gray}${pink_bg}[!] Checking dependencies${reset}"
    for prog in "${DEPENDENCIES[@]}"; do

        for i in $(seq 50); do
            echo -ne "${gray}.${reset}"
            sleep 0.01
        done

        # Is the binary installed?
        if [ -f "/usr/bin/$prog" ] || [ -f "/opt/local/bin/$prog" ]; then
            echo -e "\t[-] $prog -> ${green}$OK${reset}"

        else
            echo -e "\t[-] $prog -> ${red}$FAIL${reset}"
            exit 1
        fi
    done
}

trap cleanup SIGINT SIGTERM

function cleanup() {
    # Remove temporary file on aborting
    if [ -e "${noext}.wav" ]; then
        rm "${noext}.wav" >/dev/null 2>&1
    fi
}

function run() {
    # Main function
    file_path="${WD}/${file}"

    if [[ -f $file_path ]]; then

        # Remove extesion
        noext=${file_path/.txt/}
        # Text to wav
        espeak -f "$file_path" -v en-us -w "$noext.wav" -s 150

        # Convert to mp3
        lame --quiet "${noext}".wav "${noext}".mp3 >/dev/null 2>&1

        if [[ $? -eq 0 ]]; then
            echo -e "${gray}[+] File converted to [${noext}.mp3] ${green}${OK}${reset}"
        else
            echo -e "${gray}[!] Conversion failed! $FAIL${reset}"
        fi

        # Comment it out if don't wanna play the mp3 file created
        mpg123 -q ${noext}.mp3

    else
        echo -e "${gray}${red_bg}[!] Missing argument or file does not exist!${reset}"
        show_help
    fi
}
function delete_file() {
    # Ask for deletion

    tput setaf 196 # Red color
    read -p "[!] Keep the file wav file (y/N)?"
    tput reset

    case $REPLY in
    Y | y)
        return
        ;;
    N | n)
        cleanup
        ;;
    "")
        cleanup
        ;;
    *)
        prompt_again
        ;;
    esac
}
function prompt_again() {
    # Invalid option

    clear
    delete_file
}

function show_help() {

    # Usage
    echo -ne "${gray}${pink_bg}Convert text to mp3\n${reset}"
    echo
    echo -ne "${green}\tUsage: txt2mp3 -f txt_file\n${reset}"
    echo
    echo -ne "${gray}${pink_bg}@Carlos Lacaci Moya - 2021 ;)\n${reset}"
    exit 0
}

opt_counter=0
while getopts ":hf:" option; do
    case $option in
    f)
        file=($OPTARG)
        ((opt_counter += 1))
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
shift $(($OPTIND - 1))

if [[ "$opt_counter" -eq 1 ]]; then
    dependencies
    # Star timing
    START="$(date +%s)"
    echo -ne "${gray}[!] Converting, please wait.\n${reset}"
    # Run the script
    run 2>/dev/null
    # End timing
    END="$(date +%s)"
    DURATION=$((${END} - ${START}))
    # Show timing
    echo -e "${gray}${red_bg}[+] Program took: $DURATION secs.\n${reset}"
    # Prompt for wav deletion
    delete_file
else
    show_help
fi
