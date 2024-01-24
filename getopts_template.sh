#!/bin/bash

# Declare global variables
declare -g time="" output="" file=""

# Function to display help information with more detailed descriptions
show_help() {
    echo "Usage: $0 [options] [arguments]"
    echo ""
    echo "Options:"
    echo "  -h                Display this help message and exit."
    echo "  -t TIME           Set the time. Example: -t 12:00"
    echo "  -o OUTPUT         Specify the output file. Example: -o output.txt"
    echo "  -f FILE           Specify the file to process. Example: -f input.txt"
    echo ""
    echo "Example:"
    echo "  $0 -t 12:00 -f input.txt -o output.txt"
}

# Initialize an option counter
opt_counter=0

# Process options using getopts
while getopts ":ht:o:f:" option; do
  case $option in
    t)
        time=$OPTARG
        ((opt_counter+=1))
        ;;
    o)
        output=$OPTARG
        ((opt_counter+=1))
        ;;
    f)
        file=$OPTARG
        # Validate if the file exists
        if [ ! -f "$file" ]; then
            echo "Error: File '$file' not found."
            exit 1
        fi
        ((opt_counter+=1))
        ;;
    h)
        show_help
        exit 0
        ;;
    \?)
        echo "Invalid option: -$OPTARG" >&2
        exit 1
        ;;
    :)
        echo "Option -$OPTARG requires an argument." >&2
        exit 1
        ;;
  esac
done

# Shift the positional parameters to leave only non-option arguments
shift $((OPTIND - 1))

# Check if at least one option was provided; if not, show help
if [[ $opt_counter -lt 1 ]]; then
    echo "Error: At least one option is required."
    show_help
    exit 1
else
    # Call a function to process the script (assuming process_script is defined)
    process_script
fi
