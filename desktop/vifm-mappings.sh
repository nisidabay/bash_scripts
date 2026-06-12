#!/usr/bin/env bash
#
# Show Vifm custom keys and commands via dmenu/fuzzel.
#
# Dependencies: dmenu or fuzzel, notify-send
#

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
    check_dependencies "fuzzel" "wl-copy"
    TERMINAL="kitty"

    menu() {
        fuzzel -w 80 --dmenu --match-mode=exact -p "$1"
    }
else
    # === X11 Setup ===
    check_dependencies "dmenu" "xsel"
    # shellcheck disable=SC2034
    TERMINAL="st"

    # shellcheck source=/dev/null
    if [[ -f "${HOME}/bin/dmenu_wal.sh" ]]; then
        source "${HOME}/bin/dmenu_wal.sh"
    fi

    menu() {
        dmenu -c -i -l 20 "${DMENU_APPEARANCE[@]:-}" -p "$1"
    }
fi

# List of all mappings and commands.
keys_and_commands="--- CUSTOM MAPPINGS & COMMANDS ---
Change filename (insert at start): I
Change filename (overwrite): cc
Change filename (insert at end): A
Create a directory and enter it: mkcd
Create a zip archive of selection: zip
Open config (vifmrc): ,c
Reload config: ,r
Start shell here: s
Toggle FZF (files): ,f
Toggle FZF (subshell): <C-f>
Toggle preview window: w
Toggle line wrap: ,w
Yank dir path to clipboard: yd
Yank file path to clipboard: yf

--- FILE OPERATIONS ---
Create new directory: :mkd
Create new file: :mkf
Compare files (diff): diff
Execute selected file: run
Extract current zip/tar: ex
Run 'make' in dir: make
Search inside files (grep): vgrep
Show disk usage: df
Show this help menu: mappings

--- TABS & PANES ---
Sync (Open this dir in other pane): <C-i>
Sync (Open cursor dir in other pane): <C-o>
Swap panes: sp
Toggle Single/Dual Pane: o / O
Sort dialog: S
New tab: Tn
Close tab: Tc
Next/Prev tab: Tk / Tj

--- ESSENTIAL DEFAULTS ---
Copy (Yank) selection: yy
Paste (Put) selection: p
Delete (Trash) selection: dd
Go to parent dir: h
Enter dir / Open file: l
Visual Selection: v"

main() {
    check_dependencies "notify-send"
    echo "$keys_and_commands" | menu "vifm mappings: "
}
main
