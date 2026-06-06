#!/usr/bin/env bash
#
# Show and insert common wget patterns.
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
    choice=$(printf '%s\n' "${concepts[@]}" | menu "wget Commands") || return 1

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
    "Basic - Download a single file : wget 'http://example.com/file.zip'"
    "Basic - Resume interrupted download : wget -c 'http://example.com/file.zip'"

    "Recursive - Download entire site structure : wget -r 'http://example.com/docs/'"
    "Recursive - Download with specific depth : wget -r -l 2 'http://example.com/'"
    "Recursive - Create a full offline mirror : wget --mirror --convert-links 'http://example.com/'"

    "Background - Run download in the background (log to wget-log) : wget -b 'http://example.com/largefile.iso'"

    "Safety - Wait 5 seconds between requests : wget --wait=5 'http://example.com/list/'"
    "Safety - Ignore robots.txt rules : wget -e robots=off 'http://example.com/'"

    "Reject - Download everything EXCEPT specific file types : wget -r -R '*.jpg,*.gif' 'http://example.com/'"
    "Accept - Download ONLY specific file types : wget -r -A '*.pdf' 'http://example.com/docs/'"

    "Output - Download file to specific name : wget -O custom_name.html 'http://example.com'"
    "Output - Force log to file : wget -o logfile.txt 'http://example.com/list/'"

    "Header - Custom User Agent : wget --user-agent='MyArchClient' 'http://example.com'"
    "Header - Basic Auth (user:pass) : wget --user=user --password=pass 'http://example.com/secure/'"
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
