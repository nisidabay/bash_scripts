#!/usr/bin/env bash
#
# Convert one or more aac/m4a files to mp3.
#
# Dependencies: lame, mplayer

# Constants for color codes
readonly RED=$(tput setaf 1)
readonly GREEN=$(tput setaf 46)
readonly RESET=$(tput sgr0)

# Paths to required tools
readonly MPLAYER="/usr/bin/mplayer"
readonly LAME="/usr/bin/lame"

# Default settings for file conversion
ext="aac"  # Default file extension to convert
rate="192" # Default bitrate. Acceptable values: 128, 192, 320

# Function to check if required dependencies are installed
function check_dependencies() {
    tput civis
    local -r dependencies_array=("${@}")
    local missing_dependencies=0
    for program in "${dependencies_array[@]}"; do
        if ! command -v "$program" &>/dev/null; then
            echo -e "${RED}[x]${RESET} $program ${RED}is not installed${RESET}"
            missing_dependencies=$((missing_dependencies + 1))
        else
            echo -e "${GREEN}[x]${RESET} $program ${GREEN}is installed${RESET}"
        fi
    done
    tput cnorm

    if [ "$missing_dependencies" -ne 0 ]; then
        echo -e "\n\t${RED} Install the missing programs before continuing. ${RESET}"
        exit 1
    fi
}

# Function to display error messages
function show_error() {
    tput civis
    echo -e "${RED}$*${RESET}"
    tput cnorm
}

# Function to display the help message
function show_help() {
    cat <<EOF
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
    [[ $verbose ]] && echo -en "Creating intermediate wav file..."

    if ! ${MPLAYER} -really-quiet -ao pcm "${1}" -ao pcm:file="${2}"; then
        echo ""
        show_error "Conversion to wav (${MPLAYER}) failed."
        do_cleanup
        show_error "Exiting" && exit 1
    fi

    [[ $verbose ]] && echo -e " ok"
}

# Function to convert wav to mp3 using lame
function create_mp3() {
    [[ $verbose ]] && echo -en "Creating output mp3 file..."

    if ! ${LAME} -h -b "${bitrate}" "${1}" "${2}" >/dev/null; then
        echo ""
        show_error "Conversion to mp3 (${LAME}) failed."
        do_cleanup
        show_error "Exiting" && exit 1
    fi

    [[ $verbose ]] && echo " ok"
}

# Function to perform cleanup operations
function do_cleanup() {
    [[ $verbose ]] && echo -en "Deleting intermediate file..."
    [[ ${savewav} ]] || rm -f "${2}"
    [[ ${rmm4a} ]] || rm -f "${1}"
    [[ $verbose ]] && echo " ok"
}

# Function to set the output bitrate
function set_bitrate() {
    [[ $verbose ]] && echo -en "Setting output bitrate to: $1 kbps..."
    bitrate=$1
    [[ $verbose ]] && echo " ok"
}

# Check for required dependencies
check_dependencies "lame" "mplayer"

# Parse command-line options
opt_counter=0
while getopts ":hb:e:f:v" option; do
    case $option in
    b)
        rate=${OPTARG:-$rate}
        set_bitrate "$rate"
        ((opt_counter += 1))
        ;;
    e)
        ext=${OPTARG:-$ext}
        ((opt_counter += 1))
        ;;
    f)
        file=$OPTARG
        ((opt_counter += 1))
        ;;
    v)
        verbose=true
        ((opt_counter += 1))
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
shift $((OPTIND - 1))

# Function to process file conversion
function process_conversion() {
    local ifile=$1
    local out=$(echo "${ifile}" | sed -e "s/\.${ext}//g")

    create_wav "${ifile}" "${out}.wav"
    create_mp3 "${out}.wav" "${out}.mp3"
    do_cleanup "${ifile}" "${out}.wav"
}

# Handling different use cases based on input options
if [[ $opt_counter == 0 ]]; then
    # Convert all files in current directory if they match the default extension
    for ifile in *."${ext}"; do
        if [ "${ifile}" == "*.${ext}" ]; then
            show_error "No files with extension ${ext} in this directory."
            exit 1
        fi
        process_conversion "${ifile}"
    done
else
    # Convert listed files
    for ifile in "$@"; do
        if [ ! -f "${ifile}" ]; then
            show_error "${ifile} not found."
            exit 1
        fi
        process_conversion "${ifile}"
    done
fi

exit 0
