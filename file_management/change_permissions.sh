#!/usr/bin/bash
#
# Script to change permissions for files and directories in the specified directory.

# Function to change permissions
# Args:
#   $1: Permission to set (e.g., "755")
#   $2 (optional): Directory path (default is current directory ".")
main() {
    local permission="$1"
    local path="${2:-.}"  # Use "." as default if $2 is not provided or empty

    # Change permissions for files and directories
    for item in "$path"/*; do
        if [[ -f "$item" || -d "$item" ]]; then
            chmod "$permission" "$item"
            echo "Changed permissions for: $item"
        fi
    done
}

# Check for correct number of arguments
if [[ "$#" -lt 1 ]]; then
    echo "Usage: $0 PERMISSION [DIRECTORY]"
    echo "Example: $0 755 /path/to/directory"
    echo "Example: $0 755  # for the current directory"
    exit 1
fi
# Call the main function with arguments
main "$1" "$2"
