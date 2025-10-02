#!/usr/bin/env bash
#
# Remove empty lines from a file and makes a backup copy
#

# ANSI color codes
red=$'\e[31m'
reset=$'\e[0m'

rm_empty_lines() {
    local file="$1"

    # Check if file exists and is a regular file
    if [[ ! -e "$file" ]] || [[ ! -f "$file" ]]; then
        echo "${red}[!]${reset} [$file] ${red}does not exist or is not a regular file${reset}" >&2
        return 1
    fi

    # Create backup (.bak)
    local backup="${file}.bak"
    if ! cp "$file" "$backup"; then
        echo "${red}[!]${reset} Failed to create backup: $backup" >&2
        return 1
    fi

    # Read original file and write non-empty lines to a temp file
    local temp_file="${file}.$$"
    local line
    while IFS= read -r line || [[ -n $line ]]; do
        # Check if line is non-empty (ignores whitespace-only lines)
        if [[ $line =~ [^[:space:]] ]]; then
            printf '%s\n' "$line"
        fi
    done <"$backup" >"$temp_file"

    # Replace original file with cleaned version
    if ! mv "$temp_file" "$file"; then
        echo "${red}[!]${reset} Failed to update file: $file" >&2
        rm -f "$temp_file"
        return 1
    fi
}

#--- test
rm_empty_lines "$1"
