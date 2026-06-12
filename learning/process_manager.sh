#!/usr/bin/env bash
#
# Manage system processes.
#
# Dependencies: ps, pgrep

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

list_processes() {
    local filter="${1:-}"
    local proc_dir="/proc"
    local count=0

    echo "=== Running Processes ==="
    for pid_dir in "$proc_dir"/[0-9]*; do
        [[ -d "$pid_dir" ]] || continue
        local pid="${pid_dir##*/}"
        local cmdline_file="${pid_dir}/cmdline"

        if [[ -f "$cmdline_file" ]]; then
            local cmd
            cmd=$(tr '\0' ' ' <"$cmdline_file" 2>/dev/null | sed 's/ *$//')
            cmd=${cmd:0:60}

            if [[ -n "$filter" ]]; then
                if [[ "$cmd" == *"$filter"* ]]; then
                    echo "PID: ${pid} - ${cmd}"
                    ((count++)) || true
                fi
            else
                echo "PID: ${pid} - ${cmd}"
                ((count++)) || true
            fi
        fi
    done
    echo "Total processes: ${count}"
    echo ""
}

kill_process_by_name() {
    local process_name="$1"
    if [[ -z "$process_name" ]]; then
        echo "Usage: $0 kill <process_name>" >&2
        return 1
    fi

    local pids
    mapfile -t pids < <(pgrep -f "$process_name" 2>/dev/null)

    if [[ ${#pids[@]} -eq 0 ]]; then
        echo "No processes found matching: ${process_name}"
        return 1
    fi

    echo "Found ${#pids[@]} process(es) matching '${process_name}':"
    for pid in "${pids[@]}"; do
        echo "  - PID: ${pid}"
    done

    for pid in "${pids[@]}"; do
        if kill -0 "$pid" 2>/dev/null; then
            kill "$pid" 2>/dev/null && echo "Sent SIGTERM to PID ${pid}" || echo "Failed to kill PID ${pid}"
        fi
    done
    echo ""
}

get_process_info() {
    local pid="$1"
    if [[ -z "$pid" ]]; then
        echo "Usage: $0 info <pid>" >&2
        return 1
    fi

    local proc_path="/proc/${pid}"
    if [[ ! -d "$proc_path" ]]; then
        echo "Process ${pid} not found"
        return 1
    fi

    echo "=== Process Info for PID ${pid} ==="

    if [[ -f "${proc_path}/cmdline" ]]; then
        local cmdline
        cmdline=$(tr '\0' ' ' <"${proc_path}/cmdline")
        echo "Command: ${cmdline}"
    fi

    if [[ -f "${proc_path}/status" ]]; then
        local status_file="${proc_path}/status"
        local name state ppid uid gid
        name=$(grep "^Name:" "$status_file" | cut -f2)
        state=$(grep "^State:" "$status_file" | cut -f2)
        ppid=$(grep "^PPid:" "$status_file" | cut -f2)
        uid=$(grep "^Uid:" "$status_file" | cut -f2)
        gid=$(grep "^Gid:" "$status_file" | cut -f2)

        echo "Name: ${name}"
        echo "State: ${state}"
        echo "Parent PID: ${ppid}"
        echo "User ID: ${uid}"
        echo "Group ID: ${gid}"
    fi

    local stat_file="${proc_path}/stat"
    if [[ -f "$stat_file" ]]; then
        local pid_stat
        pid_stat=$(cat "$stat_file")
        local start_time
        start_time=$(echo "$pid_stat" | cut -d' ' -f22)
        echo "Started at: ${start_time}"
    fi
    echo ""
}

get_cpu_usage() {
    echo "=== Process CPU Usage (Top 10) ==="
    ps aux --sort=-%cpu 2>/dev/null | head -n 11 | tail -n +2 | while read -r line; do
        local user pid cpu mem cmd
        pid=$(echo "$line" | awk '{print $2}')
        user=$(echo "$line" | awk '{print $1}')
        cpu=$(echo "$line" | awk '{print $3}')
        mem=$(echo "$line" | awk '{print $4}')
        cmd=$(echo "$line" | awk '{for(i=11;i<=NF;i++) printf "%s ", $i; print ""}')
        cmd=${cmd%% }
        cmd=${cmd:0:40}
        printf "%-10s PID: %-6s CPU: %-6s MEM: %-6s %s\n" "$user" "$pid" "${cpu}%" "${mem}%" "$cmd"
    done
    echo ""
}

main() {
    local command="${1:-}"
    local argument="${2:-}"

    case "$command" in
    list)
        list_processes "$argument"
        ;;
    kill)
        kill_process_by_name "$argument"
        ;;
    info)
        get_process_info "$argument"
        ;;
    cpu)
        get_cpu_usage
        ;;
    *)
        echo "Usage: $0 {list [filter]|kill <name>|info <pid>|cpu}"
        echo ""
        echo "Commands:"
        echo "  list [filter]   - List all processes, optionally filtered by name"
        echo "  kill <name>     - Kill processes by name"
        echo "  info <pid>      - Get detailed info about a process"
        echo "  cpu             - Show top CPU consuming processes"
        ;;
    esac
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
