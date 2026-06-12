#!/usr/bin/env bash
#
# Show and insert common fd commands to the terminal.
#
# Dependencies: fd, dmenu, xclip, xdotool, notify-send
# Environment: $WAYLAND_DISPLAY, $HOME

# Source appearance config (optional: check if exists)
if [[ ! -f "${HOME}/bin/dmenu_wal.sh" ]]; then
    echo "Error: dmenu_wal.sh not found" >&2
    exit 1
fi
source "${HOME}/bin/dmenu_wal.sh"

# --- FD Command Templates ---
# Format: "Description: Command Template"
declare -a fd_commands=(
    "All files: fd"
    "Case-insensitive: fd -i pattern"
    "Regex search: fd -e txt '.*log$'"
    "Search by extension: fd -e md"
    "Search in dir: fd pattern /path/to/dir"
    "Hidden files: fd --hidden pattern"
    "Ignore .gitignore: fd --no-ignore pattern"
    "Full path output: fd -a pattern"
    "Limit depth: fd -d 2 pattern"
    "Execute command: fd -x command {}"
    "Preview with fzf: fd | fzf"
    "Count matches: fd pattern | wc -l"
    "Only dirs: fd -t d pattern"
    "Only files: fd -t f pattern"
    "Symlinks included: fd -L pattern"
    "Exact name match: fd -g 'filename.txt'"
    "Show full path: fd --absolute-path pattern"
    "Exclude dir: fd pattern --exclude node_modules"
    "Search archives: fd -t x pattern"
    "JSON output: fd --json pattern"
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

# --- Function: Prompt user via dmenu. Return choice ---
prompt_user() {
    local choice
    choice=$(printf '%s\n' "${fd_commands[@]}" | dmenu -c -l 15 "${DMENU_APPEARANCE[@]}" -p "Choose fd command: ") || return 1

    # Exit if user cancels (e.g., Esc)
    [[ -z "$choice" ]] && return 1

    # Return choice
    printf '%s' "$choice"
}

# --- Function: Clean and extract command template ---
clean_selection() {
    local temp
    temp="${1#*:}" # Remove everything up to first ':'
    # Trim leading whitespace
    printf '%s' "${temp#"${temp%%[![:space:]]*}"}"
}

# --- Function: Type command into focused window ---
show_output() {
    local cmd="$1"
    if xdotool type "$cmd" 2>/dev/null; then
        return 0
    else
        echo "Warning: Could not type command — is a text field focused?" >&2
        notify-send "Warning" "Could not type command — is a text field focused?"
        return 1
    fi
}

# --- Function: Copy to clipboard ---
copy_to_clipboard() {
    local cmd="$1"
    printf '%s' "$cmd" | xclip -selection clipboard
}

# --- Function: Notify user ---
notify_user() {
    local title="$1"
    local message="$2"
    notify-send "$title" "$message"
}

# --- Main Function ---
main() {
    local choice
    local command_template

    check_dependencies "xclip" "notify-send" "dmenu" "xdotool" "fd"

    choice=$(prompt_user) || {
        echo "No selection made. Exiting." >&2
        notify-send "No selection made" "Exiting"
        exit 0
    }

    command_template=$(clean_selection "$choice")

    show_output "$command_template"
    copy_to_clipboard "$command_template"
    notify_user "FD Command Copied" "$command_template"
}

main "$@"
