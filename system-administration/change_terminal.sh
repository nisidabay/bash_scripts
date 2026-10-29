#!/usr/bin/env bash
#
# Change the terminal in i3 config.
#
# Dependencies: zenity, sed

set -euo pipefail
declare -A terminals

# Path to configuration file
CONFIG_FILE="$HOME/.config/i3/config"
# Path to terminals
CONSOLE_PATH="/usr/bin/"

# Line I want to search for
cur_term=$(sed -n "/bindsym \$mod+Return.*/p" "${CONFIG_FILE}")
# Get the terminal name
cur_term=$(echo "$cur_term" | cut -d" " -f4)

zenity --info \
    --title "Terminal Message" \
    --width 500 \
    --height 100 \
    --text "Your current terminal is: $cur_term"

# Terminals installed that I like
for console in xterm xfce4-terminal alacritty kitty terminology; do
    if [ -f "${CONSOLE_PATH}$console" ]; then
        terminals[$console]=$CONSOLE_PATH
    fi
done

selection=$(
    zenity --list \
        --title="Select terminal you want to change" \
        --column="Terminals" \
        --width 100 \
        --height 300 \
        "${!terminals[@]}"
)

# Replace and make a backup
sed -i.bak "/bindsym \$mod+Return/s/exec.*/exec $selection/g" "$CONFIG_FILE"

zenity --info \
    --title "Info Message" \
    --width 500 \
    --height 100 \
    --text "Terminal change to: $selection.\\n Refresh i3wm."
