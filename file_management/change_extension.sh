#!/usr/bin/env bash
#
# Change file extensions in the current directory.
#
# Dependencies: bash

show_help() {
    cat <<EOF
Usage: $0 -d <current_extension> -n <new_extension>

Options:
  -d EXT    Current file extension to replace (e.g., 'txt')
  -n EXT    New extension to apply (e.g., 'md')
  -h        Show this help message

Example:
  $0 -d log -n bak    # Renames *.log → *.bak

Note: Extensions should be specified WITHOUT the leading dot.
EOF
}

change_extension() {
    local current_ext="$1"
    local new_ext="$2"

    # Validate inputs
    if [[ -z "$current_ext" ]] || [[ -z "$new_ext" ]]; then
        echo "Error: Both current and new extensions must be specified." >&2
        return 1
    fi

    # Prevent same extension (avoid no-op or self-overwrite)
    if [[ "$current_ext" == "$new_ext" ]]; then
        echo "Warning: Current and new extensions are identical. Nothing to do." >&2
        return 0
    fi

    # Enable nullglob locally in a subshell to safely expand pattern
    local files
    if ! files=($(
        shopt -s nullglob
        echo *."$current_ext"
    )); then
        echo "No files found with extension .$current_ext" >&2
        return 1
    fi

    # If nullglob didn't match, array may be empty
    if [[ ${#files[@]} -eq 0 ]] || [[ "${files[0]}" == "*.$current_ext" ]]; then
        echo "No files found with extension .$current_ext" >&2
        return 1
    fi

    local file new_name
    local renamed=0
    local errors=0

    for file in "${files[@]}"; do
        # Construct new filename
        new_name="${file%."$current_ext"}.$new_ext"

        # Safety: avoid overwriting existing files
        if [[ -e "$new_name" ]]; then
            echo "Error: Cannot rename '$file' → '$new_name': target already exists." >&2
            ((errors++))
            continue
        fi

        if mv -- "$file" "$new_name"; then
            ((renamed++))
        else
            echo "Error: Failed to rename '$file'" >&2
            ((errors++))
        fi
    done

    if ((errors > 0)); then
        echo "Completed with $errors error(s). $renamed file(s) renamed." >&2
        return 1
    else
        echo "Successfully renamed ${#files[@]} file(s) from .$current_ext to .$new_ext"
        return 0
    fi
}

main() {
    local current_ext=""
    local new_ext=""

    while getopts ":d:n:h" opt; do
        case "$opt" in
        d)
            current_ext="$OPTARG"
            ;;
        n)
            new_ext="$OPTARG"
            ;;
        h)
            show_help
            exit 0
            ;;
        \?)
            echo "Invalid option: -$OPTARG" >&2
            show_help
            exit 1
            ;;
        :)
            echo "Option -$OPTARG requires an argument." >&2
            show_help
            exit 1
            ;;
        esac
    done

    # Ensure both options were provided
    if [[ -z "$current_ext" ]] || [[ -z "$new_ext" ]]; then
        echo "Error: Both -d and -n options are required." >&2
        show_help
        exit 1
    fi

    change_extension "$current_ext" "$new_ext"
}

main "$@"
