#!/usr/bin/env bash
#
# Select and copy common Bash array operations to clipboard.
#
# Dependencies: dmenu, xclip, notify-send
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
    choice=$(printf '%s\n' "${concepts[@]}" | menu "Array Operations") || return 1

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
    # -r removes the trailing newline (cleaner for pasting code)
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
    "Define - Indexed Array : my_arr=( \"one\" \"two\" \"three\" )"
    "Define - Associative Array (Map) : declare -A my_map=( [\"key\"]=\"val\" [\"foo\"]=\"bar\" )"

    "Get - All Values (Quoted) : \"\${my_arr[@]}\""
    "Get - All Values (Single String) : \"\${my_arr[*]}\""
    "Get - Specific Element : \"\${my_arr[0]}\""
    "Get - Specific Key (Map) : \"\${my_map[\"key\"]}\""

    "Count - Number of Elements : \${#my_arr[@]}"
    "Count - Length of specific element : \${#my_arr[0]}"

    "List - All Indices or Keys : \${!my_arr[@]}"

    "Modify - Append single item : my_arr+=( \"new_item\" )"
    "Modify - Append another array : my_arr+=( \"\${other_arr[@]}\" )"
    "Modify - Delete Item (by index/key) : unset 'my_arr[0]'"

    "Slice - Get subset (offset:length) : \${my_arr[@]:0:2}"

    "Loop - Iterate over Values : for val in \"\${my_arr[@]}\"; do echo \"\$val\"; done"
    "Loop - Iterate over Keys/Indices : for key in \"\${!my_map[@]}\"; do echo \"\$key \${my_map[\$key]}\"; done"

    "Magic - Split String into Array : IFS=' ' read -r -a my_arr <<< \"\$string_var\""
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
