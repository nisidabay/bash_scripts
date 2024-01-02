#!/usr/bin/bash
# idea from: $id: aac2mp3,v 1.2 2005/08/22 15:32:34 rali exp $
# Convert one or more aac/m4a files to mp3.  
# author: $id: aac2mp3,v 1.2 2005/08/22 15:32:34 rali exp $
# modified by: nisidabay
# date: vie 17 feb 2023 16:10:51 cet
# Modified: mié 27 dic 2023 11:00:10 CET
# modified by: ChatGPT
# dependencies: lame, mplayer
##############################################################################


# Color setup for output messages
red=$(tput setaf 1)
green=$(tput setaf 46)
reset=$(tput sgr0)

# Paths to required tools
mplayer="/usr/bin/mplayer"
lame="/usr/bin/lame"

# Default settings for file conversion
ext="aac"       # Default file extension to convert
rate="192"      # Default bitrate. Acceptable values: 128, 192, 320

# Function to check if required dependencies are installed
function chk_dependencies() {
    tput civis
    local -r dependencies_array=("${@}")
    local missing_dependencies=0
    for program in "${dependencies_array[@]}"; do
        if [ ! "$(command -v "$program")" ]; then
            echo "${red}[x]${reset} $program ${red}is not installed${reset}"
            missing_dependencies=$((missing_dependencies + 1))
        else
            echo "${green}[x]${reset} $program ${green}is installed${reset}"
        fi
    done
    tput cnorm

    if [ "$missing_dependencies" -ne 0 ]; then
        echo -e "\nFix the missing programs before continuing."
        exit 1
    fi
}

# Function to display error messages
function show_error() {
    tput civis
    echo "${red}$*${reset}"
    tput cnorm
}

# Function to display the help message
function show_help() {
    cat << EOF
🎶 Utility to convert music from m4a or aac format to mp3 🎶

    Usage: ${0##*/} -b [nnn] -e [aac|m4a] -f [file]
        -b [nnn] default bitrate 192
        -e [.m4a |.aac] default extension .m4a 
        -f file to convert. If omitted, convert all files by extension
        -v show verbose output
        -h show this help

    Examples:
        ${0##*/} -b [128|192|320] -e [aac|m4a] -f [audio.aac| audio.m4a]
        ${0##*/} -b 128 -e m4a -f track.m4a
        ${0##*/} -b 128 -e m4a 
📄  Version 1.0 - nisidabay 2023

EOF
}


# Function to convert aac to wav using mplayer
function create_wav() {

    [[ $verbose ]] && echo -n "Creating intermediate wav file..."

    if ! ${mplayer} -really-quiet -ao pcm "${1}" -ao pcm:file="${2}";then
        echo ""
        show_error "Conversion to wav (${mplayer}) failed."
        do_cleanup
        show_error "Exiting" && exit 1
    fi

    [[ $verbose ]] && echo " ok"
}

# Function to convert wav to mp3 using lame
function create_mp3() {

    [[ $verbose ]] && echo -n "Creating output mp3 file..."

    if ! ${lame} -h -b "${bitrate}" "${1}" "${2}" > /dev/null; then
        echo ""
        show_error "Conversion to mp3 (${lame}) failed."
        do_cleanup
        show_error "Exiting" && exit 1
    fi

    [[ $verbose ]] && echo " ok"
}

# Function to perform cleanup operations
function do_cleanup() {
    [[ $verbose ]] && echo -n "Deleting intermediate file..."
    [[ ${savewav} ]] || rm -f "${2}"
    [[ ${rmm4a} ]] || rm -f "${1}"
    [[ $verbose ]] && echo " ok"
}

# Function to set the output bitrate
function do_set_bitrate() {
    [[ $verbose ]] && echo -n "Setting output bitrate to: $1 kbps..."
    bitrate=$1
    [[ $verbose ]] && echo " ok"
}

# Check for required dependencies
chk_dependencies "lame" "mplayer"

# Parse command-line options
opt_counter=0
while getopts ":hb:e:f:v" option; do
    case $option in
        b)
            rate=${OPTARG:-$rate}
            do_set_bitrate "$rate"
            (( opt_counter+=1 ))
            ;;
        e) 
            ext=${OPTARG:-$ext}
            (( opt_counter+=1 ))
            ;;
        f) 
            file=$OPTARG
            (( opt_counter+=1 ))
            ;;
        v) 
            verbose=true
            (( opt_counter+=1 ))
            ;;
        h) 
            show_help
            exit 0
            ;;
        \?) 
            echo "Invalid option."
            show_help
            exit 1
            ;;
        *) 
            echo "Missing option argument."
            show_help
            exit 1
            ;;
    esac
done
shift $(( OPTIND - 1 ))

# Handling different use cases based on input options
if [[ $opt_counter == 0 ]]; then                    
    # Convert all files in current directory if they match the default extension
    for ifile in *."${ext}"; do
        if [ "${ifile}" == "*.${ext}" ]; then
            show_error "No files with extension ${ext} in this directory."
            exit 1
        fi

        out=$(echo "${ifile}" | sed -e "s/\.${ext}//g")

        create_wav "${ifile}" "${out}.wav"
        create_mp3 "${out}.wav" "${out}.mp3"
        do_cleanup "${ifile}" "${out}.wav"
    done
else                    
    # Convert listed files
    for ifile in "$@"; do
        test -f "${ifile}" || show_error "${ifile} not found." && exit 1

        out=$(echo "${ifile}" | sed -e "s/\.${ext}//g")

        create_wav "${ifile}" "${out}.wav"
        create_mp3 "${out}.wav" "${out}.mp3"
        do_cleanup "${ifile}" "${out}.wav"
    done
fi

exit 0
