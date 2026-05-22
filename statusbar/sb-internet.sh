#!/usr/bin/env bash
#
# Display internet connection status for dwmblocks.
#
# Dependencies: nmcli, notify-send
# Environment: $TERMINAL, $EDITOR

TERMINAL="st"
case $BLOCK_BUTTON in
1)
    "$TERMINAL" -e nmtui
    pkill -RTMIN+4 dwmblocks
    ;;
6)
    "$TERMINAL" -e "$EDITOR" "$0"
    ;;
3)
    notify-send "🌐 Internet module" "\- Click to connect
❌: wifi disabled
📡: no wifi connection
📶: wifi connection with quality
❎: no ethernet
🌐: ethernet working
🔒: vpn is active"
    ;;
esac

# Check WiFi status
if grep -xq 'up' /sys/class/net/w*/operstate 2>/dev/null; then
    wifiicon="$(awk '/^\s*w/ { print "📶", int($3 * 100 / 70) "%" }' /proc/net/wireless)"
elif grep -xq 'down' /sys/class/net/w*/operstate 2>/dev/null; then
    grep -xq '0x1003' /sys/class/net/w*/flags && wifiicon="📡 " || wifiicon="❌ "
else
    wifiicon=""
fi

# Check Ethernet status
etherneticon=$(sed "s/down/❎/;s/up/🌐/" /sys/class/net/e*/operstate 2>/dev/null)

# Check VPN status
if grep -q 'up' /sys/class/net/tun*/operstate 2>/dev/null || nordvpn status 2>/dev/null | grep -q "Connected"; then
    vpnicon="🔒"
else
    vpnicon=""
fi

# Output the result
printf "%s%s%s\n" "$wifiicon" "$etherneticon" "$vpnicon"
