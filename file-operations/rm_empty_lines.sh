#!/usr/bin/env bash
#
# Remove empty lines from a file and make a backup.
#
# Dependencies: cp, mv

red=$'\e[31m'
reset=$'\e[0m'

rm_empty_lines() {
    local file="$1"

    if [[ ! -e "$file" ]] || [[ ! -f "$file" ]]; then
        echo "${red}[!]${reset} [$file] ${red}does not exist or is not a regular file${reset}" >&2
        return 1
    fi

    local backup="${file}.bak"
    if ! cp "$file" "$backup"; then
        echo "${red}[!]${reset} Failed to create backup: $backup" >&2
        return 1
    fi

    local temp_file="${file}.$$"
    local line
    while IFS= read -r line || [[ -n $line ]]; do
        if [[ $line =~ [^[:space:]] ]]; then
            printf '%s\n' "$line"
        fi
    done <"$backup" >"$temp_file"

    if ! mv "$temp_file" "$file"; then
        echo "${red}[!]${reset} Failed to update file: $file" >&2
        rm -f "$temp_file"
        return 1
    fi
}

rm_empty_lines "$1"
