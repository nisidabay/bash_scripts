#!/usr/bin/env bash
#
# Display Bluetooth status for dwmblocks.
#
# Dependencies: bluetoothctl, notify-send

# Debugging: Log the BLOCK_BUTTON value
echo "BLOCK_BUTTON: $BLOCK_BUTTON" >>/tmp/bluetooth-debug.log

# Function to display Bluetooth status
get_bluetooth_status() {
    local bluetooth_output
    if ! command -v bluetoothctl &>/dev/null; then
        echo "Bluetoothctl not found!" >>/tmp/bluetooth-debug.log
        echo " N/A"
        return
    fi

    bluetooth_output=$(bluetoothctl show 2>/dev/null)
    echo "Bluetoothctl Output: $bluetooth_output" >>/tmp/bluetooth-debug.log

    if echo "$bluetooth_output" | grep -q "Powered: yes"; then
        echo " On"
    else
        echo " Off"
    fi
}

# Get initial Bluetooth status
icon=$(get_bluetooth_status)

# Handle mouse button clicks
case $BLOCK_BUTTON in
1) # Left click: Toggle Bluetooth status
    current_status=$(get_bluetooth_status)
    echo "Current Status: $current_status" >>/tmp/bluetooth-debug.log
    if [[ "$current_status" == " Off" ]]; then
        bluetoothctl power on >/dev/null 2>&1
        notify-send "Bluetooth" "Bluetooth turned ON"
        icon=" On"
    else
        bluetoothctl power off >/dev/null 2>&1
        notify-send "Bluetooth" "Bluetooth turned OFF"
        icon=" Off"
    fi
    ;;
2) # Middle click: Show module help
    notify-send "Bluetooth Module" "- Shows Bluetooth status\n- Left click to toggle Bluetooth\n- Middle click for detailed status."
    ;;
3) # Right click: Show detailed status
    status=$(bluetoothctl show 2>/dev/null | grep -E 'Powered|Discoverable|Pairable' | sed 's/^ *//')
    if [[ -z "$status" ]]; then
        notify-send "Bluetooth Status" "No Bluetooth adapter detected."
    else
        notify-send "Bluetooth Status" "$status"
    fi
    ;;
esac

# Output the current Bluetooth status
echo "$icon"
