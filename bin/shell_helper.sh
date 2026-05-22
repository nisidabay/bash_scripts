#!/usr/bin/env bash
#
# Select Bash test expressions and flags to insert.
#
# Dependencies: dmenu, xclip, xdotool, notify-send
# Environment: $HOME
# --- Configuration ---
# 1. Load your color theme if it exists (for dmenu colors)
if [[ -f "${HOME}/bin/dmenu_wal.sh" ]]; then
    # shellcheck disable=SC1091
    source "${HOME}/bin/dmenu_wal.sh"
fi

# 2. Define the list of options
# Format: "Description : Code"
# This format allows you to search by description in dmenu.
declare -a concepts=(
    "Check (Test) integer equals 15 : test 15 -eq 15 && echo Yes"
    "Check (Glob) string contains 'elk' : [[ \$stringvar == *elk* ]]"
    "Check (Regex) string matches pattern : [[ \$words =~ \$pattern ]]"
    "Check (Math) number > 10 : (( number > 10 ))"
    "Check (Math) number > 10 (old style) : [ \$number -gt 10 ]"

    "File - Exists : -e FILE"
    "File - Is a directory : -d FILE"
    "File - Is a regular file : -f FILE"
    "File - Is readable : -r FILE"
    "File - Is writable : -w FILE"
    "File - Is executable : -x FILE"
    "File - Is not empty : -s FILE"
    "File - Is a symbolic link : -L FILE"
    "File - Is newer than (modified) : -N FILE"
    "File - Owned by you : -O FILE"
    "File - Owned by your group : -G FILE"
)

# --- Functions ---

# Displays the menu using dmenu
menu() {
    local prompt="$1"
    # -l 15 lists 15 lines vertically
    dmenu -c -l 15 "${DMENU_APPEARANCE[@]}" -p "$prompt"
}

# Checks if you have the required programs installed
check_dependencies() {
    local missing=()
    for program in "$@"; do
        if ! command -v "$program" &>/dev/null; then
            missing+=("$program")
        fi
    done

    if [[ "${#missing[@]}" -gt 0 ]]; then
        echo "Error: Missing programs: ${missing[*]}" >&2
        notify-send "Error" "Missing programs: ${missing[*]}"
        exit 1
    fi
}

# Cleans the selection to get just the code part
# Input: "File - Exists : -e FILE" -> Output: "-e FILE"
clean_selection() {
    local input="$1"
    # Delete everything from the beginning up to the colon and space ": "
    local cleaned="${input##*: }"
    printf "%s" "$cleaned"
}

# --- Main Logic ---

main() {
    # 1. Check if tools are installed
    check_dependencies "xclip" "notify-send" "dmenu" "xdotool"

    # 2. Show menu and get user choice
    local choice
    choice=$(printf "%s\n" "${concepts[@]}" | menu "Bash Cheat Sheet")

    # 3. If user cancelled (pressed Esc), exit gracefully
    if [[ -z "$choice" ]]; then
        exit 0
    fi

    # 4. Extract the code from the description
    local selected_code
    selected_code=$(clean_selection "$choice")

    # 5. Type it into the active window
    # If xdotool fails, we just print to stdout
    if ! xdotool type "$selected_code" 2>/dev/null; then
        echo "$selected_code"
    fi

    # 6. Also copy to clipboard as a backup
    printf "%s" "$selected_code" | xclip -selection clipboard

    # 7. Send a notification
    notify-send "Bash Cheat Sheet" "Inserted: $selected_code"
}

main
