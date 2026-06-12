#!/usr/bin/env bash
#
# Display available package updates for dwmblocks.
#
# Dependencies: checkupdates, notify-send
# Environment: $TERMINAL, $EDITOR

# Get the count of available updates. The '|| true' prevents the script
# from exiting if checkupdates fails (e.g., no internet connection).
packages=$(checkupdates | wc -l || true)

# Set the icon based on the number of available packages
if [ "$packages" -gt 0 ]; then
    icon="📦" # Package icon for available updates
else
    icon="✅" # Checkmark icon for no updates
fi

# Display the package count with the appropriate icon
echo "$icon $packages"

# Handle different mouse button clicks
case "$BLOCK_BUTTON" in
1)
    # Left-click: Display a simple notification with the package count.
    notify-send "System Updates" "$packages packages available."
    ;;
2 | 3)
    # Middle/Right-click: Open a terminal to run the system update.
    # The final notification only runs if pacman succeeds (due to &&).
    update_cmd="echo '>>> Running system update...'; sudo pacman -Syu && notify-send '✅ System Updated' 'Pacman finished successfully.'; read -p '>>> Press enter to close window...'"

    # Launch the terminal detached from dwmblocks
    setsid -f "$TERMINAL" -e sh -c "$update_cmd"
    ;;
esac
