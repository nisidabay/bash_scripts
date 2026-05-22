#!/usr/bin/env bash
#
# Show and insert common curl patterns.
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
    choice=$(printf '%s\n' "${concepts[@]}" | menu "cURL Commands") || return 1

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
    "GET - Basic Request : curl 'http://example.com'"
    "POST - Send JSON data : curl -X POST -H 'Content-Type: application/json' -d '{\"key\":\"value\"}' 'http://example.com/api'"
    "PUT - Update resource : curl -X PUT -d 'data' 'http://example.com/api/1'"
    "DELETE - Remove resource : curl -X DELETE 'http://example.com/api/1'"

    "Header - Only show HTTP headers : curl -I 'http://example.com'"
    "Header - Verbose output (show request/response headers) : curl -v 'http://example.com'"
    "Header - Custom User Agent : curl -H 'User-Agent: MyCustomAgent' 'http://example.com'"

    "File - Download to file (original name) : curl -O 'http://example.com/file.zip'"
    "File - Download to file (custom name) : curl -o custom.zip 'http://example.com/file.zip'"
    "File - Upload a file (POST) : curl -F 'file=@/path/to/local/file.txt' 'http://example.com/upload'"
    "File - Resume interrupted download : curl -C -O 'http://example.com/largefile.iso'"

    "Security - Follow Redirects : curl -L 'http://old.url'"
    "Security - Ignore SSL certificate warnings : curl -k 'https://insecure.site'"
    "Auth - Basic Auth (user:pass) : curl -u user:password 'http://example.com/api'"

    "Progress - Show simple progress bar : curl -sS 'http://example.com'"
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
