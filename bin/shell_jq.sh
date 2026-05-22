#!/usr/bin/env bash
#
# Show and insert common jq patterns.
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
    choice=$(printf '%s\n' "${concepts[@]}" | menu "jq JSON Patterns") || return 1

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
    # -r removes the trailing newline
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
    "Basic - Pretty print (color/format) : jq '.'"
    "Basic - Compact output (minified) : jq -c '.'"
    "Output - Raw string (remove quotes) : jq -r '.key'"

    "Get - Value of specific key : jq '.keyName'"
    "Get - Value of nested key : jq '.parent.child'"
    "Get - Value inside array (index 0) : jq '.[0]'"
    "Get - Multiple fields (as array) : jq '[.user, .id]'"

    "Slice - First 5 items of array : jq '.[0:5]'"
    "Slice - Last 5 items of array : jq '.[-5:]'"

    "Map - Create new object structure : jq '{name: .name, id: .id}'"
    "Map - Extract specific key from array of objects : jq 'map(.id)'"

    "Filter - Select items where price > 100 : jq 'select(.price > 100)'"
    "Filter - Select items matching text regex : jq 'select(.name | test(\"pattern\"))'"

    "Inspect - List all keys of object : jq 'keys'"
    "Inspect - Get length of array or string : jq 'length'"

    "Sort - Sort array of objects by field : jq 'sort_by(.date)'"
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
