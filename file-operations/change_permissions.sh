#!/usr/bin/env bash
#
# Change permissions for files and directories.
#
# Dependencies: chmod

main() {
    local permission="$1"
    local path="${2:-.}"

    for item in "$path"/*; do
        if [[ -f "$item" || -d "$item" ]]; then
            chmod "$permission" "$item"
            echo "Changed permissions for: $item"
        fi
    done
}

if [[ "$#" -lt 1 ]]; then
    echo "Usage: $0 PERMISSION [DIRECTORY]"
    echo "Example: $0 755 /path/to/directory"
    echo "Example: $0 755  # for the current directory"
    exit 1
fi

main "$1" "$2"
