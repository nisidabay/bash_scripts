#!/usr/bin/env bash
#
# Show and insert watch commands to monitor files and processes.
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
    choice=$(printf '%s\n' "${concepts[@]}" | menu "Watch Monitoring") || return 1

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

# Try to type the command, fallback to printing if xdotool fails
write_command() {
    local cmd="$1"
    if ! xdotool type "$cmd" 2>/dev/null; then
        echo "Could not type. Is a terminal focused?" >&2
    fi
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
    "Basic - Run every 2s (default) : watch 'ls -l'"
    "Basic - Run every 0.5s (fast) : watch -n 0.5 'ls -l'"

    "Highlight - Show changes visually : watch -d 'ls -l'"
    "Highlight - Cumulative changes (sticky) : watch -d=cumulative 'ls -l'"

    "Color - Interpret color codes : watch -c 'ls -l --color=always'"
    "Exit - Stop if command fails (errors) : watch -e 'ls -l'"
    "Exit - Stop if contents change : watch -g 'ls -l'"
    "Header - Hide header (time/interval) : watch -t 'ls -l'"

    "Recipe - Monitor File Size : watch -n 1 'du -h file.txt'"
    "Recipe - Monitor Directory Size : watch -n 1 'du -sh directory/'"
    "Recipe - Monitor File Contents (Tail) : watch -n 1 'tail -n 10 file.log'"
    "Recipe - Monitor File Hash (Integrity) : watch -n 1 'md5sum file.bin'"
    "Recipe - Monitor Network Ports : watch -n 1 'ss -tuln'"
    "Recipe - Monitor Docker Containers : watch -n 1 'docker ps'"
    "Recipe - Monitor Nvidia GPU : watch -n 1 'nvidia-smi'"
)

main() {
    local choice
    local selected_option

    check_dependencies "xclip" "dmenu" "xdotool" "notify-send"

    choice=$(prompt_user) || {
        echo "[WARNING] No selection made. Exiting." >&2
        exit 1
    }

    selected_option=$(clean_selection "$choice")

    # 1. Type it (Primary action for watch commands)
    write_command "$selected_option"

    # 2. Copy it (Backup)
    copy_to_clipboard "$selected_option"

    notify_user "[INFO] Inserted & Copied" "$selected_option"
}
main
