#!/usr/bin/env bash
#
# Show and insert common dd patterns.
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
    choice=$(printf '%s\n' "${concepts[@]}" | menu "dd Commands") || return 1

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
    "ISO - Burn to USB (Bootable) : sudo dd if=file.iso of=/dev/sdX bs=4M status=progress && sync"
    "Backup - Clone Disk to Image : sudo dd if=/dev/sdX of=backup.img bs=4M status=progress"
    "Restore - Image to Disk : sudo dd if=backup.img of=/dev/sdX bs=4M status=progress"
    "Clone - Disk to Disk (Direct) : sudo dd if=/dev/sda of=/dev/sdb bs=64K conv=noerror,sync status=progress"

    "Wipe - Zero fill disk (Erase data) : sudo dd if=/dev/zero of=/dev/sdX bs=4M status=progress"
    "Wipe - Random fill disk (Secure erase) : sudo dd if=/dev/urandom of=/dev/sdX bs=4M status=progress"

    "Test - Create 1GB dummy file : dd if=/dev/zero of=1GB.test bs=1M count=1000 status=progress"
    "Test - Benchmark Disk Write Speed : dd if=/dev/zero of=tempfile bs=1G count=1 oflag=dsync"

    "MBR - Backup Master Boot Record : sudo dd if=/dev/sdX of=mbr_backup.img bs=512 count=1"
    "MBR - Restore Master Boot Record : sudo dd if=mbr_backup.img of=/dev/sdX bs=512 count=1"

    "Text - Convert to Uppercase (Old school) : dd if=file.txt of=upper.txt conv=ucase"
    "Text - Convert to Lowercase : dd if=file.txt of=lower.txt conv=lcase"
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
