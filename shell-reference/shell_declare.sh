#!/usr/bin/env bash
#
# Select and copy Bash declare statements to clipboard.
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
        notify_user "[ERROR]" "Missing requirements: ${missing[*]}"
        exit 1
    fi
}

prompt_user() {
    local choice
    # Updated prompt text
    choice=$(printf '%s\n' "${concepts[@]}" | menu "Select declare option") || return 1

    # Exit if user cancels (e.g., Esc)
    [[ -z "$choice" ]] && return 1

    # Return choice
    printf '%s' "$choice"
}

clean_selection() {
    local input="$1"

    # Extract everything AFTER the LAST ": " sequence.
    # This keeps the code and discards the description.
    local cleaned="${input##*: }"

    printf '%s' "$cleaned"
}

copy_to_clipboard() {
    local cmd="$1"
    # -r removes the trailing newline (cleaner for pasting code)
    printf '%s' "$cmd" | xclip -selection clipboard -r
}

notify_user() {
    local title="$1"
    local message="$2"
    if command -v notify-send &>/dev/null; then
        notify-send "$title" "$message"
    fi
}

# The Core Knowledge Base: Declare flags
# Format: "Description : Code"
declare -a concepts=(
    "Integer (Math auto-eval on assignment) : declare -i var"
    "Read-only (Constant - cannot change) : declare -r var"
    "Array (Indexed - numbered list) : declare -a arr"
    "Array (Associative - key/value map) : declare -A map"
    "Export (Make available to child scripts) : declare -x var"
    "Nameref (Treat as reference to another var) : declare -n ref"
    "Lowercase (Convert value automatically) : declare -l var"
    "Uppercase (Convert value automatically) : declare -u var"
    "Global (Set global from inside function) : declare -g var"
    "Debug (Print variable value and attributes) : declare -p var"
    "Debug (Print ALL variables) : declare -p"
    "Function (Show definition code) : declare -f func_name"
    "Function (Show name only) : declare -F func_name"
)

main() {
    local choice
    local selected_option

    check_dependencies "xclip" "dmenu" "notify-send"

    choice=$(prompt_user) || {
        echo "[WARNING] No selection made. Exiting." >&2
        # Only notify if we actually failed/cancelled
        exit 1
    }

    selected_option=$(clean_selection "$choice")

    copy_to_clipboard "$selected_option"
    notify_user "[INFO] Copied to clipboard" "$selected_option"
}
main
