#!/usr/bin/env bash
#
# Quick access to common Pacman and BlackArch commands.
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
    "--- GENERAL COMMANDS ---"
    "Install package : sudo pacman -S <package>"
    "Search for package : pacman -Ss <expression>"
    "Upgrade all packages : sudo pacman -Syu"
    "Remove package (keep deps) : sudo pacman -R <package>"
    "Remove package (clean deps) : sudo pacman -Rs <package>"
    "Remove package (total nuke) : sudo pacman -Rcns <package>"

    "--- MAINTENANCE ---"
    "Clean local cache : sudo pacman -Sc"
    "List orphan dependencies : pacman -Qdtq"
    "Remove orphan dependencies : sudo pacman -Rs \$(pacman -Qdtq)"
    "List foreign/AUR packages : pacman -Qmq"

    "--- INFORMATION ---"
    "Show info (Online repo) : pacman -Si <package>"
    "Show info (Installed local) : pacman -Qi <package>"
    "List files in local package : pacman -Ql <package>"

    "--- BLACKARCH ---"
    "List all BlackArch tools : sudo pacman -Sgg | grep blackarch | cut -d' ' -f2 | sort -u"
    "List BlackArch categories : sudo pacman -Sg | grep blackarch"
    "Install a whole category : sudo pacman -S blackarch-<category>"
    "Install ALL tools (WARNING) : sudo pacman -S blackarch"
)

main() {
    local choice
    choice=$(printf '%s\n' "${concepts[@]}" | menu "Pacman Rosetta: ") || exit 1

    # Don't do anything if a header is clicked
    [[ "$choice" == --* ]] && exit 0

    local selected_option
    selected_option=$(clean_selection "$choice")

    # Copy to clipboard and notify
    printf '%s' "$selected_option" | "$COPY_CMD"
    notify-send "[INFO] Copied to clipboard" "$selected_option"
}

main
