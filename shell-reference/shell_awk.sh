#!/usr/bin/env bash
#
# Show and insert common awk patterns.
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
    choice=$(printf '%s\n' "${concepts[@]}" | menu "Awk Patterns") || return 1

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
    "Print - First Column : awk '{print \$1}'"
    "Print - First and Last Column : awk '{print \$1, \$NF}'"
    "Print - Entire Line (usually for filtering) : awk '{print \$0}'"

    "Rows - Print specific line (Row 10) : awk 'NR==10'"
    "Rows - Print range (Rows 10 to 20) : awk 'NR>=10 && NR<=20'"

    "Filter - Lines longer than 80 chars : awk 'length(\$0) > 80'"
    "Filter - Column 2 is greater than 100 : awk '\$2 > 100'"
    "Filter - Column 3 matches regex 'error' : awk '\$3 ~ /error/'"

    "Delim - Custom separator (CSV) : awk -F',' '{print \$2}'"
    "Delim - Custom separator (Colon /etc/passwd) : awk -F':' '{print \$1}'"

    "Format - Printf (align columns) : awk '{printf \"%-10s %s\\n\", \$1, \$2}'"

    "Math - Sum a column : awk '{sum+=\$1} END {print sum}'"
    "Math - Average a column : awk '{sum+=\$1} END {print sum/NR}'"

    "Inject - Add Line Number to start : awk '{print NR, \$0}'"
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
