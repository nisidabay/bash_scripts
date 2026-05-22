#!/usr/bin/env bash
#
# Display network interface information.
#

set -euo pipefail
trap 'handle_error $LINENO' ERR

handle_error() {
    echo "Error: Command failed at line $1" >&2
    exit 1
}

get_interfaces() {
    local net_dir="/sys/class/net"

    echo "=== Network Interfaces ==="
    for iface_path in "$net_dir"/*; do
        [[ -d "$iface_path" ]] || continue
        local iface="${iface_path##*/}"
        local status
        status=$(cat "${iface_path}/operstate" 2>/dev/null || echo "unknown")
        local mac
        mac=$(cat "${iface_path}/address" 2>/dev/null || echo "N/A")

        echo "Interface: ${iface}"
        echo "  Status: ${status}"
        echo "  MAC: ${mac}"

        if [[ -f "${iface_path}/mtu" ]]; then
            local mtu
            mtu=$(cat "${iface_path}/mtu")
            echo "  MTU: ${mtu}"
        fi
        echo ""
    done
}

get_ip_addresses() {
    echo "=== IP Addresses ==="

    if command -v ip &>/dev/null; then
        ip addr show 2>/dev/null | while read -r line; do
            if [[ "$line" =~ ^[0-9]+:\ ([^:]+): ]]; then
                local iface="${BASH_REMATCH[1]}"
                echo "Interface: ${iface}"
            elif [[ "$line" =~ inet\ ([0-9.]+) ]]; then
                echo "  IPv4: ${BASH_REMATCH[1]}"
            elif [[ "$line" =~ inet6\ ([a-f0-9:]+) ]]; then
                echo "  IPv6: ${BASH_REMATCH[1]}"
            fi
        done
    else
        local hostname_ip
        hostname_ip=$(hostname -I 2>/dev/null)
        if [[ -n "$hostname_ip" ]]; then
            echo "IPv4: ${hostname_ip}"
        fi
    fi
    echo ""
}

get_connections() {
    local proto="${1:-tcp}"

    echo "=== Network Connections (${proto^^}) ==="

    if [[ -f /proc/net/"$proto" ]]; then
        local count=0
        tail -n +2 /proc/net/"$proto" 2>/dev/null | while read -r line; do
            local local_addr rem_address state
            local_addr=$(echo "$line" | awk '{print $1}')
            rem_address=$(echo "$line" | awk '{print $2}')
            state=$(echo "$line" | awk '{print $3}')

            if [[ "$proto" == "tcp" || "$proto" == "udp" ]]; then
                local local_port="${local_addr##*:}"
                local local_host="${local_addr%:*}"
                local rem_port="${rem_address##*:}"
                local rem_host="${rem_address%:*}"

                local state_str=""
                if [[ "$proto" == "tcp" ]]; then
                    case "$state" in
                    01) state_str="ESTABLISHED" ;;
                    02) state_str="SYN_SENT" ;;
                    03) state_str="SYN_RECV" ;;
                    04) state_str="FIN_WAIT1" ;;
                    05) state_str="FIN_WAIT2" ;;
                    06) state_str="CLOSE_WAIT" ;;
                    07) state_str="CLOSING" ;;
                    08) state_str="TIME_WAIT" ;;
                    0A) state_str="LISTEN" ;;
                    0B) state_str="CLOSE" ;;
                    *) state_str="UNKNOWN" ;;
                    esac
                fi

                if [[ "$state_str" == "LISTEN" || "$state_str" == "ESTABLISHED" ]]; then
                    printf "%-15s:%-6s -> %-15s:%-6s [%s]\n" \
                        "$local_host" "$local_port" "$rem_host" "$rem_port" "$state_str"
                    ((count++)) || true
                fi
            fi

            [[ "$count" -gt 20 ]] && break
        done
    fi
    echo ""
}

get_port_listeners() {
    echo "=== Listening Ports ==="

    if [[ -f /proc/net/tcp ]]; then
        tail -n +2 /proc/net/tcp /proc/net/tcp6 2>/dev/null | while read -r line; do
            local local_addr state
            local_addr=$(echo "$line" | awk '{print $2}')
            state=$(echo "$line" | awk '{print $3}')

            if [[ "$state" == "0A" ]]; then
                local port_hex="${local_addr##*:}"
                local port_dec
                port_dec=$((16#${port_hex}))
                echo "Port: ${port_dec}"
            fi
        done | sort -n | uniq
    fi
    echo ""
}

get_network_stats() {
    echo "=== Network Statistics ==="

    local stat_file="/proc/net/snmp"
    if [[ -f "$stat_file" ]]; then
        grep -E "^(Ip|Icmp|Tcp|Udp):" "$stat_file" | while read -r line; do
            local name values
            name=$(echo "$line" | awk '{print $1}')
            values=$(echo "$line" | awk '{for(i=2;i<=NF;i++) printf "%s ", $i; print ""}')
            echo "${name}: ${values}"
        done
    fi
    echo ""
}

main() {
    local command="${1:-all}"

    case "$command" in
    interfaces)
        get_interfaces
        ;;
    ip)
        get_ip_addresses
        ;;
    connections)
        get_connections "${2:-tcp}"
        ;;
    ports)
        get_port_listeners
        ;;
    stats)
        get_network_stats
        ;;
    all)
        get_interfaces
        get_ip_addresses
        get_connections
        get_network_stats
        ;;
    *)
        echo "Usage: $0 {interfaces|ip|connections [proto]|ports|stats|all}"
        ;;
    esac
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
