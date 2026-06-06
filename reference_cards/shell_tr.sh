#!/usr/bin/env bash
#
# Show and insert common tr patterns.
#
# Dependencies: dmenu, xclip, xdotool, notify-send
# Environment: $HOME
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
    choice=$(printf '%s\n' "${concepts[@]}" | menu "Text Translate (tr)") || return 1

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
    "Case - Lower to UPPER : tr '[:lower:]' '[:upper:]'"
    "Case - UPPER to lower : tr '[:upper:]' '[:lower:]'"

    "Delete - Remove specific characters (e.g., digits) : tr -d '0-9'"
    "Delete - Remove all Newlines (join lines) : tr -d '\\n'"
    "Delete - Remove Carriage Returns (Windows -> Linux) : tr -d '\\r'"

    "Keep - Delete everything EXCEPT digits : tr -cd '[:digit:]'"
    "Keep - Delete everything EXCEPT printable chars : tr -cd '[:print:]'"

    "Replace - Spaces with Underscores : tr ' ' '_'"
    "Replace - Tabs with Spaces : tr '\\t' ' '"
    "Replace - Multiple chars with one (Translate set) : tr '{}' '()'"

    "Squeeze - Multiple spaces to single space : tr -s ' '"
    "Squeeze - Multiple newlines to single newline : tr -s '\\n'"

    "Fun - ROT13 Encryption : tr 'A-Za-z' 'N-ZA-Mn-za-m'"
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
