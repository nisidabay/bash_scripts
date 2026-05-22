#!/usr/bin/env bash
#
# Quick access to common acronyms via dmenu/fuzzel.
#
# Dependencies: dmenu or fuzzel, xsel/xclip or wl-copy, notify-send
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
    TERMINAL="foot"
    COPY_CMD=(wl-copy)

    menu() {
        fuzzel -w 80 --dmenu --match-mode=exact -p "$1"
    }
else
    # === X11 Setup ===
    if command -v xsel &>/dev/null; then
        COPY_CMD=(xsel --clipboard --input)
    elif command -v xclip &>/dev/null; then
        COPY_CMD=(xclip -selection clipboard)
    else
        notify-send "[ERROR]" "Missing clipboard tool: install xsel or xclip"
        exit 1
    fi
    check_dependencies "dmenu" "notify-send"
    TERMINAL="st"
    if [[ -f "${HOME}/bin/dmenu_wal.sh" ]]; then
        # shellcheck disable=SC1091
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
    "Laughing Out Loud : LOL"
    "Oh My God : OMG"
    "Be Right Back : BRB"
    "Talk To You Later : TTYL"
    "Away From Keyboard : AFK"
    "In My Opinion : IMO"
    "In My Humble Opinion : IMHO"
    "For Your Information : FYI"
    "I Don't Know : IDK"
    "To Be Honest : TBH"
    "Also Known As : AKA"
    "Never Mind : NVM"

    "I Love You : ILY"
    "Shaking My Head : SMH"
    "For The Win : FTW"
    "In Real Life : IRL"
    "Too Much Information : TMI"
    "Not Safe For Work : NSFW"

    "As Soon As Possible : ASAP"
    "Estimated Time of Arrival : ETA"
    "Do It Yourself : DIY"
    "Thank God It’s Friday : TGIF"
    "No Problem : NP"
    "You're Welcome : YW"

    "Explain Like I’m 5 : ELI5"
    "Ask Me Anything : AMA"
    "Fear Of Missing Out : FOMO"
    "Rolling On The Floor Laughing : ROFL"
    "Got To Go : GTG"
)

main() {
    local choice
    local selected_option

    # Get user selection
    choice=$(printf '%s\n' "${concepts[@]}" | menu "Acronym: ") || exit 1

    # Don't do anything if a header is clicked
    [[ "$choice" == --* ]] && exit 0

    selected_option=$(clean_selection "$choice")

    # Copy to clipboard
    printf '%s' "$selected_option" | "${COPY_CMD[@]}"

    # Notify user
    notify_user "[INFO] Copied to clipboard" "$selected_option"
}

main
