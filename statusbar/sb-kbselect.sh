#!/usr/bin/env bash
#
# Change keyboard layout via dmenu for dwmblocks.
#
# Dependencies: dmenu, setxkbmap
# Environment: $TERMINAL, $EDITOR

# shellcheck disable=SC1091
# Source appearance config
if [[ ! -f "${HOME}/bin/dmenu_wal.sh" ]]; then
    echo "Error: dmenu_wal.sh not found" >&2
    exit 1
fi
source "${HOME}/bin/dmenu_wal.sh"

menu() {
    local prompt="$1"
    dmenu -c -l 15 "${DMENU_APPEARANCE[@]}" -p "$prompt"
}

# Get the current keyboard layout
kb=$(setxkbmap -query | grep -oP 'layout:\s*\K\w+') || exit 1

case $BLOCK_BUTTON in
# Left click: Choose a new keyboard layout
1)
    kb_choice=$(awk '/! layout/{flag=1; next} /! variant/{flag=0} flag {print $2, "- " $1}' /usr/share/X11/xkb/rules/base.lst | menu "Select keyboard layout")
    [ -z "$kb_choice" ] && exit 0
    kb=$(echo "$kb_choice" | awk '{print $3}')
    setxkbmap "$kb"
    pkill -RTMIN+30 "${STATUSBAR:-dwmblocks}"
    ;;
# Right click: Show notification with current layout
3)
    notify-send "⌨ Keyboard/Language Module" "$(printf "Current layout: %s\n- Left click to change keyboard." "$kb")"
    ;;
esac

# Output the current keyboard layout
echo "$kb"
