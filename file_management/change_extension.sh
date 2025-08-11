#!/usr/bin/env bash
#
# Change files extension
#

# Function to display help message
function show_help() {
    echo "Usage: $0 -d <default_extension> -n <new_extension>"
    echo "Change the extension of all files with the specified default extension to the new extension."
}

# Function to change file extensions
function change_extension() {
    local default_ext="$1"
    local new_ext="$2"

    # Check if the correct number of arguments is provided
    if [[ -z "$default_ext" || -z "$new_ext" ]]; then
        show_help
        return 1
    fi

    # Check if there are files with the specified default extension
    shopt -s nullglob
    local files=(*."$default_ext")
    shopt -u nullglob

    if [[ ${#files[@]} -eq 0 ]]; then
        echo "No files found with the extension .$default_ext"
        return 1
    fi

    # Loop through files and change their extensions
    for file in "${files[@]}"; do
        if ! mv "$file" "${file%."$default_ext"}.$new_ext"; then
            echo "Failed to rename $file"
            return 1
        fi
    done

    echo "File extensions changed from .$default_ext to .$new_ext"
}

# Main function to execute the script
function main() {
    local default_ext=""
    local new_ext=""

    while getopts ":d:n:h" opt; do
        case ${opt} in
            d )
                default_ext="$OPTARG"
                ;;
            n )
                new_ext="$OPTARG"
                ;;
            h )
                show_help
                exit 0
                ;;
            \? )
                show_help
                exit 1
                ;;
        esac
    done

    change_extension "$default_ext" "$new_ext"
}

main "$@"
