#!/usr/bin/env bash
#
# Show and insert shell redirection patterns.
#
# Dependencies: dmenu or fuzzel, xsel or wl-copy, notify-send
# Environment: $WAYLAND_DISPLAY, $HOME
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

# --- Environment Detection & Setup ---

if [[ -n "$WAYLAND_DISPLAY" ]]; then
    # === Wayland Setup ===
    check_dependencies "wl-copy" "notify-send" "fuzzel"
    TERMINAL="foot"
    COPY_CMD="wl-copy"

    # Wrapper for fuzzel to behave like dmenu
    menu() {
        local prompt="$1"
        # --dmenu: read from stdin
        # --match-mode=exact: behavior closer to standard dmenu
        fuzzel --dmenu --match-mode=exact -p "$prompt" -w 80
    }

else
    # === X11 Setup ===
    check_dependencies "xclip" "notify-send" "dmenu"
    TERMINAL="st"
    COPY_CMD="xsel -ib"

    # Source your wal colors if available
    if [[ -f "${HOME}/bin/dmenu_wal.sh" ]]; then
        source "${HOME}/bin/dmenu_wal.sh"
    fi

    # Wrapper for dmenu
    menu() {
        local prompt="$1"
        # Uses DMENU_APPEARANCE from your dmenu_wal.sh if sourced
        dmenu -c -i -l 20 "${DMENU_APPEARANCE[@]:-}" -p "$prompt"
    }
fi

prompt_user() {

    local choice
    choice=$(printf '%s\n' "${concepts[@]}" | menu "Shell redirection: ") || return 1

    # Exit if user cancels (e.g., Esc)
    [[ -z "$choice" ]] && return 1

    # Return choice
    printf '%s' "$choice"
}

clean_selection() {
    local temp
    temp="${1#*:}" # Remove everything up to first from "$1" ':'
    # Trim leading whitespace
    printf '%s' "${temp#"${temp%%[![:space:]]*}"}"
}

copy_to_clipboard() {
    local cmd="$1"
    printf '%s' "$cmd" | "$COPY_CMD"
}

notify_user() {
    local title="$1"
    local message="$2"
    notify-send "$title" "$message" -t 2000
}

declare -a concepts=(
    "Arithmetic expansion (POSIX): \$((expression))"
    "Cmd sequence: cmd1;cmd2"
    "Command substitution (POSIX): \$(cmd2)"
    "Exec cmd1 && cmd2: cmd1 && cmd2"
    "Exec cmd1 || cmd2: cmd1 || cmd2"
    "Exec cmds in subshell: (cmd1; cmd2)"
    "Exec command group: { cmd1; cmd2; }"
    "Explicit stdin redirection (FD 0): sort 0< file.txt"
    "Explicit stdout redirection (FD 1): echo 'out' 1> file"
    "FD close reading: exec 3<&-"
    "FD close writing: exec 3>&-"
    "FD create for reading: exec 3< input.log"
    "FD create for writing: exec 3> output.log"
    "FD read from: cat <&3"
    "FD write to: echo 'message' >&3"
    "Here string: <<< string (bashism)"
    "Heredocs indented (tabs only): cmd <<- EOF"
    "Heredocs: cmd << EOF"
    "Implicit stdin redirection: sort < file.txt"
    "Implicit stdout redirection: echo 'out' > file"
    "Output from cmd1 to cmd2: cmd1 | cmd2"
    "Output to null (POSIX): cmd >/dev/null 2>&1"
    "Output to null: cmd &>/dev/null (bashism)"
    "Redirect stderr to stdout: cmd 2>&1"
    "Redirect stdout to stderr: cmd 1>&2"
    "Redirect stdout to stderr: >&2 (bashism)"
    "Redirect stdout/stderr to same file: cmd &> file (bashism)"
    "Redirect stdout/stderr to same file: cmd > file 2>&1"
    "Redirect stdout/stderr to separate files: cmd > output.log 2> errors.log"
)

main() {
    local choice
    local selected_option

    choice=$(prompt_user) || {
        echo "[WARNING] No selection made. Exiting." >&2
        notify-send "[WARNING] No selection made" "Exiting"
        exit 1
    }

    selected_option=$(clean_selection "$choice")

    copy_to_clipboard "$selected_option"
    notify_user "[INFO] Copy to clipboard" "$selected_option"
}
main
