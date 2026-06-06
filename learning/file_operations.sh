#!/usr/bin/env bash
#
# Perform common file operations.
#

set -euo pipefail
trap 'handle_error $LINENO' ERR

handle_error() {
    echo "Error: Command failed at line $1" >&2
    exit 1
}

list_directory() {
    local path="${1:-.}"
    local show_hidden="${2:-false}"

    if [[ ! -d "$path" ]]; then
        echo "Error: Directory not found: ${path}" >&2
        return 1
    fi

    echo "=== Directory Listing: ${path} ==="

    local count=0
    local dir_count=0
    local file_count=0

    for entry in "$path"/*; do
        [[ -e "$entry" ]] || continue

        local name="${entry##*/}"

        if [[ "$show_hidden" != "true" && "${name:0:1}" == "." ]]; then
            continue
        fi

        ((count++)) || true

        if [[ -d "$entry" ]]; then
            ((dir_count++)) || true
            echo "${name}/"
        elif [[ -f "$entry" ]]; then
            ((file_count++)) || true
            local size
            size=$(stat -c%s "$entry" 2>/dev/null || echo "0")
            echo "${name} (${size} bytes)"
        elif [[ -L "$entry" ]]; then
            local target
            target=$(readlink "$entry")
            echo "${name} -> ${target} (symlink)"
        fi
    done

    echo ""
    echo "Total: ${count} items (${dir_count} directories, ${file_count} files)"
    echo ""
}

get_file_info() {
    local file="$1"

    if [[ ! -e "$file" ]]; then
        echo "Error: File not found: ${file}" >&2
        return 1
    fi

    local name="${file##*/}"
    local dir="${file%/*}"
    if [[ "$dir" == "$file" ]]; then
        dir="."
    fi

    echo "=== File Info: ${name} ==="
    echo "Name: ${name}"
    echo "Directory: ${dir}"

    if [[ -d "$file" ]]; then
        echo "Type: Directory"
    elif [[ -f "$file" ]]; then
        echo "Type: Regular File"
    elif [[ -L "$file" ]]; then
        echo "Type: Symbolic Link"
    else
        echo "Type: Unknown"
    fi

    if [[ -f "$file" || -L "$file" ]]; then
        local size
        size=$(stat -c%s "$file" 2>/dev/null || echo "0")
        echo "Size: ${size} bytes"
    fi

    if [[ -f "$file" ]]; then
        local perms
        perms=$(stat -c "%a" "$file" 2>/dev/null || echo "unknown")
        echo "Permissions: ${perms}"

        local owner group
        owner=$(stat -c "%U" "$file" 2>/dev/null || echo "unknown")
        group=$(stat -c "%G" "$file" 2>/dev/null || echo "unknown")
        echo "Owner: ${owner}:${group}"
    fi

    local mtime
    mtime=$(stat -c "%y" "$file" 2>/dev/null || echo "unknown")
    echo "Modified: ${mtime}"

    if [[ -L "$file" ]]; then
        local target
        target=$(readlink "$file")
        echo "Target: ${target}"
    fi
    echo ""
}

find_files() {
    local directory="${1:-.}"
    local pattern="${2:-*}"
    local search_type="${3:-name}"

    if [[ ! -d "$directory" ]]; then
        echo "Error: Directory not found: ${directory}" >&2
        return 1
    fi

    echo "=== Finding files in ${directory} ==="
    echo "Pattern: ${pattern}"
    echo ""

    local count=0
    while IFS= read -r -d '' file; do
        ((count++)) || true

        if [[ "$search_type" == "name" ]]; then
            local name="${file##*/}"
            echo "$file"
        elif [[ "$search_type" == "path" ]]; then
            echo "$file"
        elif [[ "$search_type" == "ext" ]]; then
            local ext="${file##*.}"
            if [[ "$ext" != "$file" ]]; then
                echo "${ext}: $file"
            fi
        fi
    done < <(find "$directory" -print0 2>/dev/null)

    echo ""
    echo "Found: ${count} file(s)"
    echo ""
}

compare_files() {
    local file1="$1"
    local file2="$2"

    if [[ ! -f "$file1" ]]; then
        echo "Error: File not found: ${file1}" >&2
        return 1
    fi

    if [[ ! -f "$file2" ]]; then
        echo "Error: File not found: ${file2}" >&2
        return 1
    fi

    echo "=== Comparing Files ==="
    echo "File 1: ${file1}"
    echo "File 2: ${file2}"
    echo ""

    local size1 size2
    size1=$(stat -c%s "$file1" 2>/dev/null || echo "0")
    size2=$(stat -c%s "$file2" 2>/dev/null || echo "0")

    if [[ "$size1" -eq "$size2" ]]; then
        echo "Same size: ${size1} bytes"
    else
        echo "Different sizes: ${size1} vs ${size2} bytes"
    fi

    if cmp -s "$file1" "$file2"; then
        echo "Content: IDENTICAL"
    else
        echo "Content: DIFFERENT"
    fi
    echo ""
}

get_largest_files() {
    local directory="${1:-.}"
    local count="${2:-10}"

    if [[ ! -d "$directory" ]]; then
        echo "Error: Directory not found: ${directory}" >&2
        return 1
    fi

    if ! [[ "$count" =~ ^[0-9]+$ ]]; then
        echo "Error: Invalid count: ${count}" >&2
        return 1
    fi

    echo "=== Largest ${count} Files in ${directory} ==="

    local temp_file
    temp_file=$(mktemp)

    while IFS= read -r -d '' file; do
        if [[ -f "$file" ]]; then
            local size
            size=$(stat -c%s "$file" 2>/dev/null || echo "0")
            local name="${file##*/}"
            echo "${size} ${file}" >>"$temp_file"
        fi
    done < <(find "$directory" -print0 2>/dev/null)

    sort -rn "$temp_file" 2>/dev/null | head -n "$count" | while read -r size path; do
        local size_display
        if [[ "$size" -lt 1024 ]]; then
            size_display="${size} B"
        elif [[ "$size" -lt 1048576 ]]; then
            size_display="$((size / 1024)) KB"
        elif [[ "$size" -lt 1073741824 ]]; then
            size_display="$((size / 1048576)) MB"
        else
            size_display="$((size / 1073741824)) GB"
        fi
        printf "%-10s %s\n" "$size_display" "$path"
    done

    rm -f "$temp_file"
    echo ""
}

main() {
    local command="${1:-}"
    local arg1="${2:-}"
    local arg2="${3:-}"
    local arg3="${4:-}"

    case "$command" in
    ls)
        list_directory "${arg1:-.}" "${arg2:-false}"
        ;;
    info)
        get_file_info "$arg1"
        ;;
    find)
        find_files "$arg1" "${arg2:-*}" "${arg3:-name}"
        ;;
    compare)
        compare_files "$arg1" "$arg2"
        ;;
    largest)
        get_largest_files "${arg1:-.}" "${arg2:-10}"
        ;;
    *)
        echo "Usage: $0 {ls|info|find|compare|largest} [args]"
        echo ""
        echo "Commands:"
        echo "  ls [dir] [show_hidden]    - List directory contents"
        echo "  info <file>               - Get detailed file info"
        echo "  find <dir> [pattern]      - Find files matching pattern"
        echo "  compare <file1> <file2>   - Compare two files"
        echo "  largest [dir] [count]     - Show largest files"
        ;;
    esac
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
