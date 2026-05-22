#!/usr/bin/env bash
#
# Show and insert common sort patterns.
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
    choice=$(printf '%s\n' "${concepts[@]}" | menu "Sort Lines") || return 1

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
    "Numeric - Sort numbers correctly (1, 2, 10) : sort -n"
    "Human - Sort file sizes (1K, 1M, 1G) : sort -h"
    "Version - Sort version numbers (v1.2, v1.10) : sort -V"

    "Reverse - Descending order (Z-A, 9-0) : sort -r"
    "Unique - Remove duplicates : sort -u"
    "Case - Ignore case (treat A same as a) : sort -f"

    "Random - Shuffle lines : sort -R"

    "Column - Sort by 2nd column : sort -k 2"
    "Column - Sort by 3rd column (Numeric) : sort -k 3n"
    "Column - CSV (comma separator, 2nd col) : sort -t ',' -k 2"
    "Column - /etc/passwd (colon separator, 3rd col UID) : sort -t ':' -k 3n"

    "Check - Exit with error if NOT sorted : sort -c"
    "Output - Write result to file (safe in-place) : sort -o file.txt file.txt"

    "Stable - Keep original order of identical lines : sort -s"
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
