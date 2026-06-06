#!/usr/bin/env bash
#
# Show and insert fd/find comparison commands to the terminal.
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
        printf "[ERROR] Missing required programs: %s\n" "${missing[*]}" >&2
        notify_user "[ERROR]" "Missing requirements"
        exit 1
    fi
}

prompt_user() {
    local choice
    choice=$(printf "%s\n" "${concepts[@]}" | menu "fd/find comparison") || true

    # Exit if user cancels (e.g., Esc)
    [[ -z "$choice" ]] && return 1

    # Return choice
    printf "%s" "$choice"
}

clean_selection() {
    local input="$1"
    # Remove everything up to and including the first ": "
    # This handles "label: value" cleanly
    local cleaned="${input##*: }" # ⬅️ Note the SPACE after colon

    # Fallback: if no ": " found, try just ":"
    if [[ "$cleaned" == "$input" ]]; then
        cleaned="${input##*:}"
        # Trim leading space manually
        cleaned="${cleaned#"${cleaned%%[![:space:]]*}"}"
    fi

    printf "%s" "$cleaned"
}

show_output() {
    local cmd="$1"
    if xdotool type "$cmd" 2>/dev/null; then
        return 0
    else
        printf "%s\n" "$cmd"
        return 0
    fi
}

copy_to_clipboard() {
    local cmd="$1"
    printf "%s" "$cmd" | xclip -selection clipboard
}

notify_user() {
    local title="$1"
    local message="$2"
    notify-send "$title" "$message"
}

declare -a concepts=(
    "fd Search by Name: fd backup",
    "find Search by Name: find . -type f -iname \"backup\"",
    "fd Search by Extension: fd -e py script.py",
    "find Search by Extension: find . -type f -name \"*.py\" -name \"script\"",
    "fd Search by File Type: fd -t d logs",
    "find Search by File Type: find . -type d -name \"logs\"",
    "fd Search by Size (>1MB): fd -S +1m",
    "find Search by Size (>1MB): find . -type f -size +1M",
    "fd Search by Modification Time (< 1h): fd --changed-within 1h",
    "find Search by Modification Time (< 1h): find . -type f -mmin -60",
    "fd Search with Exclusion: fd -E '.git'",
    "find Search with Exclusion: find . -name '.git' -prune -o -print",
    "fd Search Hidden Files: fd -H pattern",
    "find Search Hidden Files: find . -name '.*' -o -name 'pattern'"
)

main() {
    local choice
    local selected_option

    check_dependencies "xclip" "notify-send" "dmenu" "xdotool"

    choice=$(prompt_user) || {
        echo "[WARNING] No selection made. Exiting." >&2
        notify_user "[WARNING]" "No selection made"
        exit 1
    }

    selected_option=$(clean_selection "$choice")

    show_output "$selected_option" &&
        copy_to_clipboard "$selected_option" &&
        notify_user "[INFO] Typed & copied" "$selected_option"
}
main
