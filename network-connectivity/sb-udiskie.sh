#!/usr/bin/env bash
#
# Mount USB drives with udiskie for dwmblocks.
#
# Dependencies: udiskie, dmenu, lsblk, notify-send
# Environment: $TERMINAL, $EDITOR
# Apply DMENU_APPEARANCE
if [[ ! -f "${HOME}/bin/dmenu_wal.sh" ]]; then
    echo "Error: dmenu_wal.sh not found" >&2
    exit 1
fi
source "${HOME}/bin/dmenu_wal.sh"

menu() {
    local prompt="$1"
    dmenu -c -i -l 20 "${DMENU_APPEARANCE[@]:-}" -p "$prompt"
}

# 1. Get the count of mounted USB drives
# We filter for drives mounted under /run/media/USER to avoid system partitions
mounted_drives=$(lsblk -nrpo MOUNTPOINT | grep "^/run/media/$USER" | wc -l)

# 2. Handle Mouse Clicks
case "$BLOCK_BUTTON" in
1)
    # Left-click: Launch lf
    setsid -f "$TERMINAL" -e sh -c "lf /run/media/$USER"
    ;;
2)
    # Middle-click: Mount all (Simple fix for unmounted drives)
    notify-send "USB" "Mounting all devices..."
    udiskie-mount -a
    ;;
3)
    # Right-click: DMENU MENU to unmount a SPECIFIC drive

    # Get list of mounted drives (Format: "Label (Mountpoint)")
    # We use lsblk to get the mountpoint and label, then format it for dmenu
    list=$(lsblk -nrpo MOUNTPOINT,LABEL | grep "^/run/media/$USER")

    if [ -z "$list" ]; then
        notify-send "USB" "No removable drives mounted."
    else
        # Show dmenu and get user selection
        chosen=$(echo "$list" | menu "Unmount which drive?" | awk '{print $1}')

        # If a choice was made, unmount it
        if [ -n "$chosen" ]; then
            notify-send "USB" "Unmounting $chosen..."
            udiskie-umount "$chosen"
        fi
    fi
    ;;
esac

# 3. Display the Output
if [ "$mounted_drives" -gt 0 ]; then
    echo " $mounted_drives"
else
    echo " 0"
fi
