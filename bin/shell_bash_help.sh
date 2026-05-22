#!/usr/bin/env bash
#
# Open Bash help page in dmenu.
#
# Dependencies: dmenu, terminal
# Environment: $TERMINAL, $HOME

# --- Configuration ---

# shellcheck disable=SC1091
source "${HOME}/bin/dmenu_wal.sh"

TERMINAL="${TERMINAL:-st}"

# --- Mac notification ---
notify_mac() {
    local title="$1"
    local message="$2"
    osascript -e "display notification \"$message\" with title \"$title\""
}

# --- Linux notification ---
notify_linux() {
    local title="$1"
    local message="$2"
    notify-send -u normal "$title" "$message" --icon=dialog-information
}

# --- Notification handler ---
notify() {
    local title="$1"
    local message="$2"

    if [[ $(uname -s) =~ "Linux" ]]; then
        notify_linux "$title" "$message"
    elif [[ $(uname -s) == "Darwin" ]]; then
        notify_mac "$title" "$message"
    fi
}

# --- Entry point ---
main() {
    search=$(compgen -b | dmenu -c -i -l 20 "${DMENU_APPEARANCE[@]}" -p "Find Bash help page:")
    #
    # Run the search and open a new terminal window to display the result
    "$TERMINAL" -e bash -c "help \"$search\" | tee \"${search}.txt\" && echo \"Help for '$search' saved to ${search}.txt\" && read -p 'Press Enter to close...'"

    notify "$search" "Save to ${search}.txt"
}

main
