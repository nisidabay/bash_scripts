#!/usr/bin/env bash
#
# Show and insert shell prompt variables to the terminal.
#
# Dependencies: dmenu, xclip, xdotool, notify-send
# Environment: $HOME

# Source appearance config
# shellcheck disable=SC1091
if [[ ! -f "${HOME}/bin/dmenu_wal.sh" ]]; then
    echo "[ERROR]: dmenu_wal.sh not found" >&2
    exit 1
fi
source "${HOME}/bin/dmenu_wal.sh"

menu() {
    local prompt="$1"
    dmenu -c -i -l 20 "${DMENU_APPEARANCE[@]:-}" -p "$prompt"
}

declare -a prompts=(
    "12-hour am/pm time: \@"
    "12-hour time: \T"
    "24-hour time: \t"
    "Basename of current directory: \W"
    "Color code: \[\033[<code>m\]"
    "Cwd: \w"
    "Full hostname: \H"
    "Literal backslash: '\\\'"
    "Newline: \n"
    "Regular users: \\$"
    "Reset color: \[\033[0m\]"
    "Short hostname: \h"
    "Username: \u"
)

# --- Function: Check required dependencies ---
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
        printf 'Error: Missing required programs: %s\n' "${missing[*]}" >&2
        notify_user "Error" "Missing requirements"
        exit 1
    fi
}

prompt_user() {
    local choice
    choice=$(printf '%s\n' "${prompts[@]}" | menu "PS1 prompts") || return 1

    [[ -z "$choice" ]] && return 1

    printf '%s' "$choice"
}

clean_selection() {
    local temp
    temp="${1#*:}" # Remove everything up to first from "$1" ':'
    # Trim leading whitespace
    printf '%s' "${temp#"${temp%%[![:space:]]*}"}"
}

show_output() {
    local cmd="$1"
    if xdotool type "$cmd" 2>/dev/null; then
        return 0
    else
        echo "[Warning]" "Could not type command"
        notify-send "[Warning]" "Could not type command"
        return 1
    fi
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

main() {
    local choice
    local selected_option

    check_dependencies "xclip" "notify-send" "dmenu" "xdotool"

    choice=$(prompt_user) || {
        echo "[ERROR]" "No selection made" >&2
        notify-send "[ERROR]" "No selection made"
        exit 1
    }

    selected_option=$(clean_selection "$choice")

    show_output "$selected_option"
    copy_to_clipboard "$selected_option"
    notify_user "[INFO] Copy to clipboard" "$selected_option"
}
main
