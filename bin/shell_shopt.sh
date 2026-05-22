#!/usr/bin/env bash
#
# Quick access to common Bash shopt options.
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
    "--- EXTGLOB SYNTAX REFERENCE ---"
    "Pattern - Match zero or one : ?(pattern-list)"
    "Pattern - Match zero or more : *(pattern-list)"
    "Pattern - Match one or more : +(pattern-list)"
    "Pattern - Match exactly one : @(pattern-list)"
    "Pattern - Match anything EXCEPT : !(pattern-list)"

    "--- GLOBBING ---"
    "Glob - Verify if extglob is ON : shopt extglob"
    "Glob - Recursive matching (** matches subdirs) : shopt -s globstar"
    "Glob - Extended patterns (like @(list)) : shopt -s extglob"
    "Glob - Case-insensitive file matching : shopt -s nocaseglob"
    "Glob - Include dotfiles (hidden files) in * : shopt -s dotglob"
    "Glob - Remove pattern if no match found (no error) : shopt -s nullglob"
    "Glob - Error if pattern matches nothing (safety) : shopt -s failglob"

    "--- NAVIGATION ---"
    "Nav - Auto-correct typos in 'cd' : shopt -s cdspell"
    "Nav - 'cd' to directory just by typing name : shopt -s autocd"
    "Nav - Auto-correct typos in dir completion : shopt -s dirspell"
    "Nav - Expand variables in dir completion : shopt -s direxpand"

    "--- HISTORY ---"
    "History - Append instead of overwrite : shopt -s histappend"
    "History - Save multi-line commands as one entry : shopt -s cmdhist"
    "History - Check hash before running from hist : shopt -s histverify"

    "--- SCRIPTING & WINDOW ---"
    "Script - Expand aliases in scripts : shopt -s expand_aliases"
    "Script - Inherit 'set -e' in subshells : shopt -s inherit_errexit"
    "Window - Update LINES/COLUMNS on resize : shopt -s checkwinsize"

    "--- UTILS ---"
    "List all ENABLED options : shopt -s"
    "List all DISABLED options : shopt -u"
    "Print options in reusable format : shopt -p"
)

main() {
    local choice
    choice=$(printf '%s\n' "${concepts[@]}" | menu "Bash Option : ") || exit 1

    # Don't do anything if a header is clicked
    [[ "$choice" == --* ]] && exit 0

    local selected_option
    selected_option=$(clean_selection "$choice")

    # Copy to clipboard and notify
    printf '%s' "$selected_option" | "$COPY_CMD"
    notify_user "[INFO] Copied to clipboard" "$selected_option"
}

main
