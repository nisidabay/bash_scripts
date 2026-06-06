#!/usr/bin/env bash
#
# Quick access to Conventional Commit message prefixes.
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
    # Using array for command + arguments to ensure correct execution
    COPY_CMD=("wl-copy")

    menu() {
        fuzzel -w 60 --dmenu --match-mode=exact -p "$1"
    }
else
    # === X11 Setup ===
    check_dependencies "dmenu" "xsel" "notify-send"
    TERMINAL="st"
    # Using array for command + arguments to ensure correct execution
    COPY_CMD=("xsel" "-ib")

    if [[ -f "${HOME}/bin/dmenu_wal.sh" ]]; then
        # shellcheck source=/dev/null
        source "${HOME}/bin/dmenu_wal.sh"
    fi

    menu() {
        dmenu -c -i -l 20 "${DMENU_APPEARANCE[@]:-}" -p "$1"
    }
fi

clean_selection() {
    # Extract everything BEFORE the first " : " separator
    printf '%s' "${1%%:* }"
}

# List format: "Label : ClipboardContent"
declare -a git_types=(
    "--- PRIMARY TYPES ---"
    "feat     (New feature) : feat: "
    "fix      (Bug fix) : fix: "
    "docs     (Documentation changes) : docs: "
    "style    (Formatting, missing semi-colons, etc) : style: "

    "--- REFACTORING & PERFORMANCE ---"
    "refactor (Code change that neither fixes a bug nor adds a feature) : refactor: "
    "perf     (Code change that improves performance) : perf: "

    "--- MAINTENANCE ---"
    "test     (Adding missing tests or correcting existing tests) : test: "
    "build    (Changes that affect the build system or external dependencies) : build: "
    "ci       (Changes to CI configuration files and scripts) : ci: "
    "chore    (Other changes that don't modify src or test files) : chore: "
    "revert   (Reverts a previous commit) : revert: "

    "--- SCOPED EXAMPLES ---"
    "feat(scope) : feat(): "
    "fix(scope)  : fix(): "
)

main() {
    local choice
    choice=$(printf '%s\n' "${git_types[@]}" | menu "Commit type: ") || exit 1

    # Don't do anything if a header is clicked
    [[ "$choice" == --* ]] && exit 0

    local selected_option
    selected_option=$(clean_selection "$choice")

    # Pipe to the command array correctly
    printf '%s' "$selected_option" | "${COPY_CMD[@]}"
    notify_user "[GIT]" "Copied: $selected_option"
}

main
