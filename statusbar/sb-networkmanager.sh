#!/usr/bin/env bash
#
# Show network connection info.
#
# Dependencies: NetworkManager, curl

dwm_networkmanager() {
    CONNAME=$(nmcli -a | grep 'Wired connection' | awk 'NR==1{print $1}')
    if [ "$CONNAME" = "" ]; then
        CONNAME=$(nmcli -t -f active,ssid dev wifi | grep '^yes' | cut -c 5-)
    fi
    PRIVATE=$(nmcli -a | grep 'inet4 192' | awk '{print $2}')
    PUBLIC=$(curl -s https://ipinfo.io/ip)

    if [ -n "$PRIVATE"]; then
        PRIVATE=$(nmcli -a | grep 'inet4 192' | awk '{print $2}')
    fi

    # if [ "$IDENTIFIER" = "unicode" ]; then
    if [ "$IDENTIFIER" = "" ]; then
        # export __DWM_BAR_NETWORKMANAGER__="${SEP1} ${CONNAME} ${PRIVATE} ${PUBLIC}${SEP2}"
        export __DWM_BAR_NETWORKMANAGER__="${SEP1} ${PRIVATE} ${SEP2}"
    else
        export __DWM_BAR_NETWORKMANAGER__="${SEP1}🌐 ${CONNAME} ${PRIVATE} ${PUBLIC}${SEP2}"
    fi
}

dwm_networkmanager
