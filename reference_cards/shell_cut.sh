#!/usr/bin/env bash
#
# Show and insert common cut patterns.
#
# Dependencies: dmenu, xclip, xdotool, notify-send
# Environment: $WAYLAND_DISPLAY, $HOME

# shellcheck disable=SC1091
# Source appearance config
if [[ ! -f "${HOME}/bin/dmenu_wal.sh" ]]; then
    echo "Error: dmenu_wal.sh not found" >&2
    exit 1
fi
source "${HOME}/bin/dmenu_wal.sh"

menu() {
    local prompt="$1"
    # -i for case-insensitive matching
    dmenu -i -c -l 15 "${DMENU_APPEARANCE[@]}" -p "$prompt"
}

check_dependencies() {
    local -a dependencies=("$@")
    local -a missing=()
    local program

    for program in "${dependencies[@]}"; do
        if ! command -v "$program" &>/dev/null; then
            missing+=("$program")
        fi
    done

    if [[ "${#missing[@]}" -gt 0 ]]; then
        printf '[ERROR] Missing required programs: %s\n' "${missing[*]}" >&2
        notify_user "[ERROR]" "Missing requirements"
        exit 1
    fi
}

prompt_user() {
    local choice
    choice=$(printf '%s\n' "${concepts[@]}" | menu "Cut Columns") || return 1

    # Exit if user cancels (e.g., Esc)
    [[ -z "$choice" ]] && return 1

    # Return choice
    printf '%s' "$choice"
}

clean_selection() {
    local input="$1"

    # Extract everything AFTER the LAST ": " sequence.
    local cleaned="${input##*: }"

    printf '%s' "$cleaned"
}

copy_to_clipboard() {
    local cmd="$1"
    # -r removes the trailing newline (cleaner for pasting after a pipe)
    printf '%s' "$cmd" | xclip -selection clipboard -r
}

notify_user() {
    local title="$1"
    local message="$2"
    if command -v notify-send &>/dev/null; then
        notify-send "$title" "$message"
    fi
}

# Format: "Description : Code"
declare -a concepts=(
    "CSV - Get 2nd Column : cut -d ',' -f 2"
    "CSV - Get 2nd and 4th Columns : cut -d ',' -f 2,4"
    "CSV - Get Columns 1 through 3 : cut -d ',' -f 1-3"
    "CSV - Get Column 3 to the END : cut -d ',' -f 3-"

    "Passwd - Get Usernames (Col 1 of :) : cut -d ':' -f 1"
    "Passwd - Get Shells (Col 7 of :) : cut -d ':' -f 7"

    "Space - Get 2nd word (Single space delimiter) : cut -d ' ' -f 2"
    "Tab - Get 1st Column (Default delimiter) : cut -f 1"

    "Chars - First 5 characters only : cut -c 1-5"
    "Chars - From 10th char to end : cut -c 10-"

    "Inverse - Print everything EXCEPT 1st column : cut -f 1 --complement"
    "Format - Change delimiter (CSV input -> Pipe output) : cut -d ',' -f 1,2 --output-delimiter=' | '"
)

main() {
    local choice
    local selected_option

    check_dependencies "xclip" "dmenu" "notify-send"

    choice=$(prompt_user) || {
        echo "[WARNING] No selection made. Exiting." >&2
        exit 1
    }

    selected_option=$(clean_selection "$choice")

    copy_to_clipboard "$selected_option"
    notify_user "[INFO] Copied to clipboard" "$selected_option"
}
main
