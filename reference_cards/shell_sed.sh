#!/usr/bin/env bash
#
# Show and insert common sed patterns.
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
    choice=$(printf '%s\n' "${concepts[@]}" | menu "Sed Patterns") || return 1

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
    "Replace - First occurrence per line : sed 's/find/replace/'"
    "Replace - ALL occurrences (Global) : sed 's/find/replace/g'"
    "Replace - Case Insensitive : sed 's/find/replace/I'"
    "Replace - Only on lines matching 'foo' : sed '/foo/s/find/replace/'"

    "Delete - Lines containing 'error' : sed '/error/d'"
    "Delete - Empty lines : sed '/^$/d'"
    "Delete - First line : sed '1d'"
    "Delete - Lines 1 through 5 : sed '1,5d'"

    "Print - Only matching lines (Emulate grep) : sed -n '/pattern/p'"
    "Print - Specific line number (e.g., line 10) : sed -n '10p'"

    "File - Edit IN-PLACE (Save changes) : sed -i 's/foo/bar/g' file.txt"
    "File - Edit in-place with Backup : sed -i.bak 's/foo/bar/g' file.txt"

    "Insert - Add line BEFORE match : sed '/match/i New_Line_Text'"
    "Insert - Add line AFTER match : sed '/match/a New_Line_Text'"

    "Trim - Remove leading whitespace : sed 's/^[ \\t]*//'"
    "Trim - Remove trailing whitespace : sed 's/[ \\t]*$//'"

    "Capture - Swap words (Group 1 and 2) : sed 's/\\(\w\+\\) \\(\w\+\\)/\\2 \\1/'"
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
