#!/usr/bin/env bash
#
# Display system information.
#
# Dependencies: df, free, uptime

set -euo pipefail
trap 'handle_error $LINENO' ERR

handle_error() {
    echo "Error: Command failed at line $1" >&2
    exit 1
}

fatal() {
    echo "FATAL: $1" >&2
    exit "${2:-1}"
}

check_dependencies() {
    local required_tools=("df" "free" "uptime")
    for tool in "${required_tools[@]}"; do
        if ! command -v "$tool" &>/dev/null; then
            fatal "Missing required tool: $tool"
        fi
    done
}

get_system_info() {
    local hostname="${HOSTNAME:-$(hostname)}"
    local kernel
    kernel=$(uname -r)
    local uptime_info
    uptime_info=$(uptime -p 2>/dev/null || uptime)
    local load_avg
    load_avg=$(cat /proc/loadavg 2>/dev/null || echo "0.00 0.00 0.00")

    echo "=== System Information ==="
    echo "Hostname: ${hostname}"
    echo "Kernel: ${kernel}"
    echo "Uptime: ${uptime_info}"
    echo "Load Average: ${load_avg}"
    echo ""
}

get_memory_info() {
    local meminfo="/proc/meminfo"
    if [[ -f "$meminfo" ]]; then
        local total used
        total=$(grep MemTotal "$meminfo" | awk '{print $2}')
        used=$(grep MemAvailable "$meminfo" | awk '{print $2}')
        if [[ -z "$used" ]]; then
            used=$(grep MemFree "$meminfo" | awk '{print $2}')
        fi
        local total_mb used_mb avail_mb percent
        total_mb=$((total / 1024))
        used_mb=$((used / 1024))
        avail_mb=$((total_mb - used_mb))
        percent=$((used_mb * 100 / total_mb))

        echo "=== Memory Usage ==="
        echo "Total: ${total_mb} MB"
        echo "Used: ${used_mb} MB"
        echo "Available: ${avail_mb} MB"
        echo "Usage: ${percent}%"
        echo ""
    fi
}

get_disk_usage() {
    local df_output
    df_output=$(df -h 2>/dev/null | tail -n +2)

    echo "=== Disk Usage ==="
    while IFS= read -r line; do
        local filesystem size used use_percent mount_point
        filesystem=$(echo "$line" | awk '{print $1}')
        size=$(echo "$line" | awk '{print $2}')
        used=$(echo "$line" | awk '{print $3}')
        use_percent=$(echo "$line" | awk '{print $5}')
        mount_point=$(echo "$line" | awk '{print $6}')

        use_percent=${use_percent%\%}
        if [[ -n "$use_percent" && "$use_percent" =~ ^[0-9]+$ ]]; then
            if [[ "$use_percent" -gt 90 ]]; then
                echo "${filesystem}: ${size} (USED: ${used}) ${mount_point} - WARNING"
            else
                echo "${filesystem}: ${size} (USED: ${used}) ${mount_point}"
            fi
        else
            echo "${filesystem}: ${size} (USED: ${used}) ${mount_point}"
        fi
    done <<<"$df_output"
    echo ""
}

get_top_processes() {
    echo "=== Top 5 CPU Processes ==="
    if [[ -f /proc/stat ]]; then
        ps aux --sort=-%cpu 2>/dev/null | head -n 6 | tail -n +2 | while read -r line; do
            local pid user cpu mem command
            pid=$(echo "$line" | awk '{print $2}')
            user=$(echo "$line" | awk '{print $1}')
            cpu=$(echo "$line" | awk '{print $3}')
            mem=$(echo "$line" | awk '{print $4}')
            command=$(echo "$line" | awk '{print $11}')
            command=${command:0:50}
            echo "PID: ${pid} User: ${user} CPU: ${cpu}% Mem: ${mem}% Cmd: ${command}"
        done
    fi
    echo ""
}

main() {
    check_dependencies
    get_system_info
    get_memory_info
    get_disk_usage
    get_top_processes
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
