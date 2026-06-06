#!/usr/bin/env bash
#
# Quick access to common find commands.
#
# Dependencies: dmenu or fuzzel, xsel or wl-copy, notify-send
# Environment: $WAYLAND_DISPLAY, $HOME

notify_user() {
    local title="$1" message="$2" severity="$3"
    notify-send -u "${severity:-normal}" "$title" "$message" -t 2000
}

check_dependencies() {
    local -a dependencies=("$@")
    local missing=()
    for program in "${dependencies[@]}"; do
        if ! command -v "$program" &>/dev/null; then
            missing+=("$program")
        fi
    done

    if [[ "${#missing[@]}" -gt 0 ]]; then
        notify-send "[ERROR]" "Missing: ${missing[*]}"
        exit 1
    fi
}

# --- Configuration ---
if [[ -n "$WAYLAND_DISPLAY" ]]; then
    # === Wayland Setup ===
    check_dependencies "fuzzel" "wl-copy" "notify-send"
    TERMINAL="kitty"
    COPY_CMD="wl-copy"

    menu() {
        fuzzel -w 80 --dmenu --match-mode=exact -p "$1"
    }
else
    # === X11 Setup ===
    check_dependencies "dmenu" "xsel" "notify-send"
    TERMINAL="st"
    COPY_CMD="xsel -ib"

    if [[ -f "${HOME}/bin/dmenu_wal.sh" ]]; then
        source "${HOME}/bin/dmenu_wal.sh"
    fi

    menu() {
        dmenu -c -i -l 20 "${DMENU_APPEARANCE[@]:-}" -p "$1"
    }
fi

clean_selection() {
    # Extract everything AFTER the last ": "
    printf '%s' "${1##*: }"
}

# Command List: "Description : Command"
declare -a concepts=(
    "--- BASIC USAGE ---"
    "Find files by name : find . -name 'filename'"
    "Case insensitive name : find . -iname 'filename'"
    "Find by size (greater than 100M) : find . -type f -size +100M"
    "Find by size (less than 1K) : find . -type f -size -1k"
    "Find by modification time (last 24h) : find . -type f -mtime -1"
    "Find by modification time (older than 7 days) : find . -type f -mtime +7"
    "Find directories only : find . -type d"
    "Find files only : find . -type f"
    "Find empty files/directories : find . -empty"

    "--- ADVANCED FILTERING ---"
    "Find by specific permission : find . -perm 644"
    "Find by specific owner : find /home -user 'username'"
    "Find by regex pattern : find . -iregex '.*\.txt$'"
    "Find files with 'pattern' in name : find . -name '*pattern*'"
    "Find files NOT containing 'pattern' : find . ! -name '*pattern*'"

    "--- ACTIONS ---"
    "Delete files found : find . -name '*.tmp' -delete"
    "Execute command on files (rm) : find . -name '*.jpg' -exec rm {} +"
    "Execute command on files (mv) : find . -name '*.txt' -exec mv {} /tmp \;"
    "List files with detailed output : find . -type f -ls"
    "Find and list permissions: find /home -perm -u=x -ls"
)

main() {
    local choice
    choice=$(printf '%s\n' "${concepts[@]}" | menu "Find command : ") || exit 1

    # Don't do anything if a header is clicked
    [[ "$choice" == --* ]] && exit 0

    local selected_option
    selected_option=$(clean_selection "$choice")

    # Copy to clipboard and notify
    printf '%s' "$selected_option" | "$COPY_CMD"
    notify_user "[INFO] Copied to clipboard" "$selected_option"
}

main
