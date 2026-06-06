#!/usr/bin/env bash
#
# Copy common Bash special and built-in variables to clipboard.
#
# Dependencies: dmenu, xclip, notify-send
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
    choice=$(printf '%s\n' "${concepts[@]}" | menu "Bash special variables") || return 1

    # Exit if user cancels (e.g., Esc)
    [[ -z "$choice" ]] && return 1

    # Return choice
    printf '%s' "$choice"
}

clean_selection() {
    local temp
    # 1. Extract everything before the first ':'
    temp="${1%%:*}"

    # 2. Trim trailing whitespace (removes the space before the colon)
    temp="${temp%"${temp##*[![:space:]]}"}"

    printf '%s' "$temp"
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

declare -a concepts=(
    "\$!: PID of the last command run in the background"
    "\$#: The total number of positional arguments"
    "\$$: The Process ID (PID) of the current shell"
    "\$-: The current options set for the shell"
    "\$*: All positional arguments as a single string"
    "\$?: The exit status of the last executed command (0 for success)"
    "\$@: All positional arguments as separate, quoted strings"
    "\$_: The last argument of the previous command"
    "\$0: The name of the script being executed"
    "\$1...\$n: The individual positional arguments passed to a script"
    "BASH_REMATCH: Array of matches from the last regex comparison"
    "BASH_SOURCE: Source filename (reliable for finding script directory)"
    "BASH_VERSION: The version of the Bash shell you're running"
    "EUID: The effective User ID of the current user"
    "FUNCNAME: The name of the current function being executed"
    "HOME: The path to the current user's home directory"
    "HOSTNAME: The hostname of the machine"
    "IFS: Internal Field Separator (defaults to space/tab/newline)"
    "LINENO: The current line number within the script or function"
    "OLDPWD: The previous working directory (used by cd -)"
    "OSTYPE: The operating system type (e.g., linux-gnu)"
    "PATH: A colon-separated list of directories to search for commands"
    "PIPESTATUS: Array containing exit statuses of the last pipeline"
    "PWD: The current working directory"
    "RANDOM: A random integer between 0 and 32767"
    "SECONDS: The number of seconds since the script was started"
    "UID: The User ID of the current user"
    "USER: The username of the current user"
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
