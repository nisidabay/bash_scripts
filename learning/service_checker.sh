#!/usr/bin/env bash
#
# Check systemd service status.
#
# Dependencies: systemctl, pgrep

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

check_service_status() {
    local service="$1"

    if [[ -z "$service" ]]; then
        echo "Error: Service name required" >&2
        return 1
    fi

    echo "=== Service Status: ${service} ==="

    if command -v systemctl &>/dev/null; then
        if systemctl list-unit-files "$service.service" 2>/dev/null | grep -q "$service.service"; then
            local status
            status=$(systemctl is-active "$service" 2>/dev/null || echo "unknown")
            echo "Status: ${status}"

            if [[ "$status" == "active" ]]; then
                local enabled
                enabled=$(systemctl is-enabled "$service" 2>/dev/null || echo "unknown")
                echo "Enabled: ${enabled}"

                local active_since
                active_since=$(systemctl show "$service" -p ActiveEnterTimestamp --value 2>/dev/null)
                if [[ -n "$active_since" ]]; then
                    echo "Active since: ${active_since}"
                fi
            else
                local failed_reason
                failed_reason=$(systemctl show "$service" -p Result --value 2>/dev/null)
                if [[ -n "$failed_reason" && "$failed_reason" != "success" ]]; then
                    echo "Failure reason: ${failed_reason}"
                fi
            fi
        else
            echo "Service not found: ${service}"
        fi
    elif command -v service &>/dev/null; then
        if service "$service" status &>/dev/null; then
            echo "Status: running"
        else
            echo "Status: stopped"
        fi
    else
        if pgrep -x "$service" &>/dev/null; then
            echo "Status: running"
        else
            echo "Status: stopped"
        fi
    fi
    echo ""
}

list_running_services() {
    echo "=== Running Services ==="

    if command -v systemctl &>/dev/null; then
        systemctl list-units --type=service --state=running 2>/dev/null | grep "\.service" | while read -r line; do
            local name status
            name=$(echo "$line" | awk '{print $1}')
            status=$(echo "$line" | awk '{print $4}')
            if [[ -n "$name" && "$name" != "UNIT" ]]; then
                echo "${name%.service}: ${status}"
            fi
        done
    elif [[ -d /etc/init.d ]]; then
        for service in /etc/init.d/*; do
            [[ -x "$service" ]] || continue
            local name="${service##*/}"
            if service "$name" status &>/dev/null; then
                echo "${name}: running"
            fi
        done
    fi
    echo ""
}

check_port_service() {
    local port="$1"

    if [[ -z "$port" ]]; then
        echo "Error: Port number required" >&2
        return 1
    fi

    if ! [[ "$port" =~ ^[0-9]+$ ]]; then
        echo "Error: Invalid port: ${port}" >&2
        return 1
    fi

    echo "=== Service on Port ${port} ==="

    if [[ -f /proc/net/tcp ]]; then
        local found=0
        local hex_port
        printf -v hex_port '%04X' "$port"

        while IFS= read -r line; do
            local local_addr
            local_addr=$(echo "$line" | awk '{print $2}')
            local port_hex="${local_addr##*:}"

            if [[ "$port_hex" == "$hex_port" ]]; then
                local inode
                inode=$(echo "$line" | awk '{print $10}')

                for pid_dir in /proc/[0-9]*; do
                    local pid="${pid_dir##*/}"
                    local fd_dir="${pid_dir}/fd"

                    if [[ -d "$fd_dir" ]]; then
                        for fd in "$fd_dir"/*; do
                            if [[ -L "$fd" ]]; then
                                local link
                                link=$(readlink "$fd" 2>/dev/null || true)
                                if [[ "$link" == *"socket:\[${inode}\]"* ]]; then
                                    local cmd
                                    cmd=$(tr '\0' ' ' <"${pid_dir}/cmdline" 2>/dev/null | sed 's/ *$//')
                                    cmd=${cmd%% }
                                    cmd=${cmd##*/}
                                    echo "Process: ${cmd} (PID: ${pid})"
                                    ((found++)) || true
                                fi
                            fi
                        done
                    fi
                done
            fi
        done </proc/net/tcp

        if [[ "$found" -eq 0 ]]; then
            echo "No service found on port ${port}"
        fi
    fi
    echo ""
}

check_common_services() {
    local services=("sshd" "nginx" "apache2" "docker" "mysql" "postgres" "redis-server" "cron")

    echo "=== Common Services Status ==="

    for service in "${services[@]}"; do
        if pgrep -x "$service" &>/dev/null; then
            echo "${service}: running"
        else
            echo "${service}: stopped"
        fi
    done
    echo ""
}

get_service_logs() {
    local service="$1"
    local lines="${2:-20}"

    if [[ -z "$service" ]]; then
        echo "Error: Service name required" >&2
        return 1
    fi

    if ! [[ "$lines" =~ ^[0-9]+$ ]]; then
        echo "Error: Invalid line count: ${lines}" >&2
        return 1
    fi

    echo "=== Last ${lines} Log Lines: ${service} ==="

    if command -v journalctl &>/dev/null; then
        journalctl -u "$service" -n "$lines" --no-pager 2>/dev/null || echo "No logs available"
    elif [[ -f "/var/log/${service}.log" ]]; then
        tail -n "$lines" "/var/log/${service}.log" 2>/dev/null || echo "Cannot read log"
    elif [[ -f "/var/log/${service}" ]]; then
        tail -n "$lines" "/var/log/${service}" 2>/dev/null || echo "Cannot read log"
    else
        echo "Log location unknown"
    fi
    echo ""
}

restart_service() {
    local service="$1"

    if [[ -z "$service" ]]; then
        echo "Error: Service name required" >&2
        return 1
    fi

    echo "Restarting ${service}..."

    if command -v systemctl &>/dev/null; then
        if systemctl restart "$service" 2>/dev/null; then
            echo "Service restarted successfully"
        else
            fatal "Failed to restart service"
        fi
    elif command -v service &>/dev/null; then
        if service "$service" restart 2>/dev/null; then
            echo "Service restarted successfully"
        else
            fatal "Failed to restart service"
        fi
    else
        fatal "No service manager found"
    fi
    echo ""
}

main() {
    local command="${1:-}"
    local arg1="${2:-}"
    local arg2="${3:-}"

    case "$command" in
    status)
        check_service_status "$arg1"
        ;;
    running)
        list_running_services
        ;;
    port)
        check_port_service "$arg1"
        ;;
    common)
        check_common_services
        ;;
    logs)
        get_service_logs "$arg1" "${arg2:-20}"
        ;;
    restart)
        restart_service "$arg1"
        ;;
    *)
        echo "Usage: $0 {status|running|port|common|logs|restart} [args]"
        echo ""
        echo "Commands:"
        echo "  status <service>      - Check service status"
        echo "  running               - List all running services"
        echo "  port <number>         - Find service on port"
        echo "  common                - Check common services"
        echo "  logs <service> [n]    - Get last n log lines"
        echo "  restart <service>     - Restart a service"
        ;;
    esac
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
