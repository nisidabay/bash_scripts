#!/usr/bin/env bash
#
# Show and insert shell parameter expansions.
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
    # Note: We now list Description first, then Code
    choice=$(printf '%s\n' "${concepts[@]}" | menu "Shell parameter expansion") || return 1

    # Exit if user cancels (e.g., Esc)
    [[ -z "$choice" ]] && return 1

    # Return choice
    printf '%s' "$choice"
}

clean_selection() {
    local input="$1"

    # Extract everything AFTER the LAST ": " sequence.
    # We use ## (longest match from start) to ensure we skip any colons
    # that might appear inside the Description itself.
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

# format: "Description : Code"
declare -a concepts=(
    "Use default if unset : \${var:-default}"
    "Assign and use default if unset : \${var:=default}"
    "Use default if var is set and not empty : \${var:+default}"
    "Exit with error if unset : \${var:?error}"

    "Length of variable : \${#var}"
    "Quote variable (safe for reuse/debug) : \${var@Q}"

    "Remove shortest prefix (start) : \${var#pat}"
    "Remove longest prefix (start) : \${var##pat}"
    "Remove shortest suffix (end) : \${var%pat}"
    "Remove longest suffix (end) : \${var%%pat}"

    "Replace first match : \${var/pat/repl}"
    "Replace all matches : \${var//pat/repl}"
    "Replace match at start only : \${var/#pat/repl}"
    "Replace match at end only : \${var/%pat/repl}"

    "Substring (start:length) : \${var:0:1}"

    "Uppercase all : \${var^^}"
    "Uppercase first character : \${var^}"
    "Lowercase all : \${var,,}"
    "Lowercase first character : \${var,}"

    "Indirect reference (value of var name) : \${!var}"
    "Get array keys or indices : \${!array[@]}"
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
