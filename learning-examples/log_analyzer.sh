#!/usr/bin/env bash
#
# Parse and analyze log files.
#
# Dependencies: none

set -euo pipefail
trap 'handle_error $LINENO' ERR

handle_error() {
    echo "Error: Command failed at line $1" >&2
    exit 1
}

analyze_log_file() {
    local log_file="$1"

    if [[ ! -f "$log_file" ]]; then
        echo "Error: File not found: ${log_file}" >&2
        return 1
    fi

    local total_lines=0
    local error_count=0
    local warning_count=0
    local info_count=0

    while IFS= read -r line || [[ -n "$line" ]]; do
        ((total_lines++)) || true

        local line_lower="${line,,}"

        if [[ "$line_lower" == *"error"* || "$line_lower" == *"fail"* || "$line_lower" == *"fatal"* ]]; then
            ((error_count++)) || true
        elif [[ "$line_lower" == *"warn"* ]]; then
            ((warning_count++)) || true
        elif [[ "$line_lower" == *"info"* ]]; then
            ((info_count++)) || true
        fi
    done <"$log_file"

    echo "=== Log Analysis: ${log_file##*/} ==="
    echo "Total Lines: ${total_lines}"
    echo "Errors: ${error_count}"
    echo "Warnings: ${warning_count}"
    echo "Info: ${info_count}"
    echo ""
}

extract_errors() {
    local log_file="$1"
    local output_file="${2:-}"

    if [[ ! -f "$log_file" ]]; then
        echo "Error: File not found: ${log_file}" >&2
        return 1
    fi

    echo "=== Extracting Error Lines ==="

    local temp_file
    temp_file=$(mktemp)

    while IFS= read -r line || [[ -n "$line" ]]; do
        local line_lower="${line,,}"
        if [[ "$line_lower" == *"error"* || "$line_lower" == *"fail"* || "$line_lower" == *"exception"* ]]; then
            echo "$line" >>"$temp_file"
        fi
    done <"$log_file"

    if [[ -n "$output_file" ]]; then
        cp "$temp_file" "$output_file"
        echo "Errors saved to: ${output_file}"
    else
        cat "$temp_file"
    fi

    rm -f "$temp_file"
    echo ""
}

get_log_timestamps() {
    local log_file="$1"

    if [[ ! -f "$log_file" ]]; then
        echo "Error: File not found: ${log_file}" >&2
        return 1
    fi

    echo "=== Log Timestamps (First 10) ==="

    local count=0
    while IFS= read -r line || [[ -n "$line" ]]; do
        ((count++)) || true
        [[ "$count" -gt 10 ]] && break

        local timestamp=""
        if [[ "$line" =~ ^([0-9]{4}-[0-9]{2}-[0-9]{2}\ [0-9]{2}:[0-9]{2}:[0-9]{2}) ]]; then
            timestamp="${BASH_REMATCH[1]}"
        elif [[ "$line" =~ ^([A-Z][a-z]{2}\ [0-9]{1,2}\ [0-9]{2}:[0-9]{2}:[0-9]{2}) ]]; then
            timestamp="${BASH_REMATCH[1]}"
        fi

        if [[ -n "$timestamp" ]]; then
            local truncated="${line:0:80}"
            echo "${timestamp} - ${truncated}"
        else
            local truncated="${line:0:100}"
            echo "${truncated}"
        fi
    done <"$log_file"
    echo ""
}

tail_log() {
    local log_file="$1"
    local num_lines="${2:-10}"

    if [[ ! -f "$log_file" ]]; then
        echo "Error: File not found: ${log_file}" >&2
        return 1
    fi

    if ! [[ "$num_lines" =~ ^[0-9]+$ ]]; then
        echo "Error: Invalid number of lines: ${num_lines}" >&2
        return 1
    fi

    echo "=== Last ${num_lines} Lines of ${log_file##*/} ==="

    local count=0
    local lines=()

    while IFS= read -r line || [[ -n "$line" ]]; do
        lines+=("$line")
        if [[ ${#lines[@]} -gt "$num_lines" ]]; then
            unset 'lines[0]'
        fi
    done <"$log_file"

    for line in "${lines[@]}"; do
        echo "$line"
    done
    echo ""
}

search_log() {
    local log_file="$1"
    local search_term="$2"

    if [[ -z "$search_term" ]]; then
        echo "Error: Search term required" >&2
        return 1
    fi

    if [[ ! -f "$log_file" ]]; then
        echo "Error: File not found: ${log_file}" >&2
        return 1
    fi

    echo "=== Searching for '${search_term}' in ${log_file##*/} ==="

    local count=0
    while IFS= read -r line || [[ -n "$line" ]]; do
        if [[ "$line" == *"$search_term"* ]]; then
            ((count++)) || true
            local truncated="${line:0:120}"
            echo "$truncated"
        fi
    done <"$log_file"

    echo "Found ${count} matching line(s)"
    echo ""
}

get_log_size() {
    local log_file="$1"

    if [[ ! -f "$log_file" ]]; then
        echo "Error: File not found: ${log_file}" >&2
        return 1
    fi

    local size
    size=$(stat -c%s "$log_file" 2>/dev/null || echo "0")
    local lines
    lines=$(wc -l <"$log_file")

    local size_display
    if [[ "$size" -lt 1024 ]]; then
        size_display="${size} B"
    elif [[ "$size" -lt 1048576 ]]; then
        size_display="$((size / 1024)) KB"
    else
        size_display="$((size / 1048576)) MB"
    fi

    echo "=== Log File Info: ${log_file##*/} ==="
    echo "Size: ${size_display}"
    echo "Lines: ${lines}"
    echo ""
}

main() {
    local command="${1:-}"
    local arg1="${2:-}"
    local arg2="${3:-}"

    case "$command" in
    analyze)
        analyze_log_file "$arg1"
        ;;
    errors)
        extract_errors "$arg1" "$arg2"
        ;;
    timestamps)
        get_log_timestamps "$arg1"
        ;;
    tail)
        tail_log "$arg1" "${arg2:-10}"
        ;;
    search)
        search_log "$arg1" "$arg2"
        ;;
    info)
        get_log_size "$arg1"
        ;;
    *)
        echo "Usage: $0 {analyze|errors|timestamps|tail|search|info} <log_file> [args]"
        echo ""
        echo "Commands:"
        echo "  analyze <file>      - Analyze log file statistics"
        echo "  errors <file>       - Extract error lines"
        echo "  errors <file> <out> - Extract errors to output file"
        echo "  timestamps <file>   - Show first 10 timestamps"
        echo "  tail <file> [n]     - Show last n lines (default 10)"
        echo "  search <file> <term> - Search for term in log"
        echo "  info <file>         - Show file size and line count"
        ;;
    esac
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
