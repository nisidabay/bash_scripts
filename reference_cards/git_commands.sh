#!/usr/bin/env bash
#
# Show and insert common git commands to clipboard.
#
# Dependencies: git, dmenu, xclip, notify-send
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
    dmenu -i -c -l 20 "${DMENU_APPEARANCE[@]}" -p "$prompt"
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
    choice=$(printf '%s\n' "${concepts[@]}" | menu "Git Operations") || return 1

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
    "--- UNDO & RESET --- : "
    "Undo - Soft Reset (Keep changes staged) : git reset --soft HEAD~1"
    "Undo - Mixed Reset (Keep changes unstaged) : git reset HEAD~1"
    "Undo - Hard Reset (DESTROY changes) : git reset --hard HEAD~1"
    "Undo - Revert last commit (Safe/New Commit) : git revert HEAD"
    "Undo - Unstage a specific file : git reset HEAD"
    "Undo - Discard changes in specific file : git checkout --"

    "--- AMEND & FIX --- : "
    "Amend - Edit message & add staged files : git commit --amend"
    "Amend - Add staged files (Keep message) : git commit --amend --no-edit"
    "Fix - Interactive Rebase (Last 3 commits) : git rebase -i HEAD~3"

    "--- REBASE FLOW --- : "
    "Rebase - Onto master branch : git rebase master"
    "Rebase - Continue (After conflict) : git rebase --continue"
    "Rebase - Abort : git rebase --abort"

    "--- LOGS & STATUS --- : "
    "Log - Graph view (One line) : git log --oneline --graph --all"
    "Log - Show changes in last commit : git show HEAD"
    "Status - Short format : git status -s"
    "Diff - Staged changes : git diff --staged"

    "--- REMOTE --- : "
    "Push - Force with Lease (Safe overwrite) : git push --force-with-lease"
    "Stash - Save current changes : git stash push -m \"WIP\""
    "Stash - Pop saved changes : git stash pop"
)

main() {
    local choice
    local selected_option

    # Checks for dependencies
    check_dependencies "xclip" "dmenu" "notify-send"

    choice=$(prompt_user) || {
        echo "[WARNING] No selection made. Exiting." >&2
        exit 1
    }

    selected_option=$(clean_selection "$choice")

    # If the user selected a header line (empty command), exit
    if [[ -z "$selected_option" ]]; then
        exit 0
    fi

    copy_to_clipboard "$selected_option"
    notify_user "[GIT]" "Copied: $selected_option"
}
main
