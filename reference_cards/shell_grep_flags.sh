#!/usr/bin/env bash
#
# Show and insert common grep flags and patterns.
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
    choice=$(printf '%s\n' "${concepts[@]}" | menu "Grep Flags") || return 1

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

# Format: "Description : Code"
declare -a concepts=(
    "Recursive search (current dir) : grep -r 'pattern' ."
    "Recursive search (follow symlinks) : grep -R 'pattern' ."
    "Ignore case : grep -i"
    "Invert match (show lines that do NOT match) : grep -v"

    "Show Line Numbers : grep -n"
    "Show Filenames only (with match) : grep -l"
    "Show Filenames only (without match) : grep -L"
    "Show only the matching part (not whole line) : grep -o"
    "Show filename for each match : grep -H"
    "Hide filename (headers) : grep -h"

    "Count matching lines : grep -c"
    "Max count (stop after NUM matches) : grep -m 1"

    "Context - After (A) 3 lines : grep -A 3"
    "Context - Before (B) 3 lines : grep -B 3"
    "Context - Both sides (C) 3 lines : grep -C 3"

    "Match whole word only : grep -w"
    "Match whole line only : grep -x"
    "Match Fixed String (No Regex - faster) : grep -F"
    "Match Extended Regex (ERE) : grep -E"
    "Match Perl Regex (PCRE - powerful) : grep -P"

    "Exclude specific file : grep --exclude='*.log'"
    "Exclude directory : grep --exclude-dir='.git'"
    "Include only specific files : grep --include='*.js'"

    "Quiet (exit code 0 if found, no output) : grep -q"
    "Colorize output (force) : grep --color=always"
    "Get patterns from file : grep -f patterns.txt"
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
