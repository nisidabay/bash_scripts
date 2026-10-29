#!/usr/bin/env bash
#
# Copy shell extended globbing patterns to clipboard.
#
# Dependencies: dmenu, xclip, notify-send
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
    dmenu -c -l 15 "${DMENU_APPEARANCE[@]}" -p "$prompt"
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
    # Updated to Description first
    choice=$(printf '%s\n' "${concepts[@]}" | menu "Extended Globbing (extglob)") || return 1

    # Exit if user cancels (e.g., Esc)
    [[ -z "$choice" ]] && return 1

    # Return choice
    printf '%s' "$choice"
}

clean_selection() {
    local input="$1"

    # Extract everything AFTER the LAST ": " sequence.
    # This safely separates the description from the code.
    local cleaned="${input##*: }"

    printf '%s' "$cleaned"
}

copy_to_clipboard() {
    local cmd="$1"
    printf '%s' "$cmd" | xclip -selection clipboard
}

notify_user() {
    local title="$1"
    local message="$2"
    notify-send "$title" "$message"
}

# Format: "Description : Code"
declare -a concepts=(
    "Enable extglob (Required for these to work!) : shopt -s extglob"
    "Match Zero or One occurrence : ?(pattern)"
    "Match Zero or More occurrences : *(pattern)"
    "Match One or More occurrences : +(pattern)"
    "Match Exactly One occurrence : @(pattern)"
    "Match Anything EXCEPT pattern : !(pattern)"
    "Match Pattern A OR Pattern B : @(pattern1|pattern2)"
)

main() {
    local choice
    local selected_option

    check_dependencies "xclip" "notify-send" "dmenu"

    choice=$(prompt_user) || {
        echo "[WARNING] No selection made. Exiting." >&2
        notify-send "[WARNING] No selection made" "Exiting"
        exit 1
    }

    selected_option=$(clean_selection "$choice")

    copy_to_clipboard "$selected_option"
    notify_user "[INFO] Copied to clipboard" "$selected_option"
}
main
