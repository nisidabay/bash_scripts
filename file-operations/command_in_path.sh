#!/usr/bin/env bash
#
# Find commands or executable scripts in PATH.
#
# Dependencies: bash

find_cmd_path() {
    local cmd="$1"
    local dir

    [[ -z "$cmd" ]] && return 2

    # Absolute or relative path
    if [[ "$cmd" == */* ]]; then
        [[ -x "$cmd" ]] && {
            printf '%s\n' "$cmd"
            return 0
        } || return 1
    fi

    # Search in PATH
    local IFS=:
    for dir in $PATH; do
        [[ -z "$dir" ]] && continue
        if [[ -x "$dir/$cmd" ]]; then
            printf '%s\n' "$dir/$cmd"
            return 0
        fi
    done

    return 1
}

main() {
    local path
    if path=$(find_cmd_path "$1"); then
        printf '%s found at %s\n' "$1" "$path" >&2
        exit 0
    else
        case $? in
        1) printf '%s: not found or not executable\n' "$1" >&2 ;;
        2) printf 'Error: no command specified\n' >&2 ;;
        esac
        exit 1
    fi
}

main "$@"
