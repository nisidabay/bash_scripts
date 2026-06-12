#!/usr/bin/env bash
#
# Show active VPN connections.
#
# Dependencies: NetworkManager, NetworkManager-openvpn
# Environment: $TERMINAL, $EDITOR

dwm_vpn() {
    VPN=$(nmcli -a | grep 'VPN connection' | sed -e 's/\( VPN connection\)*$//g')

    if [ "$VPN" = "" ]; then
        VPN=$(nmcli connection | grep 'wireguard' | sed 's/\s.*$//')
    fi

    if [ "$VPN" != "" ]; then
        printf "%s" "$SEP1"
        if [ "$IDENTIFIER" = "unicode" ]; then
            printf "🔒 %s" "$VPN"
        else
            printf "VPN %s" "$VPN"
        fi
        printf "%s\n" "$SEP2"
    fi
}

dwm_vpn
