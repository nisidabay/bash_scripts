#!/usr/bin/env bash
#
# Select and display books from a USB drive.
#
# Dependencies: dmenu, zathura, notify-send

declare -A BOOKS
declare BOOKS_DIR=""

# shellcheck disable=SC1091
source "${HOME}/bin/dmenu_wal.sh"

notify_user() {
    title="$1"
    message="$2"
    severity="$3"

    case "$severity" in
    "normal")
        notify-send -u normal "$title" "$message" --icon=dialog-information
        ;;
    "critical")
        notify-send -u critical "$title" "$message" --icon=dialog-error
        ;;
    esac
}

check_dependencies() {
    local -a dependencies_array=("$@")
    local -a missing=()

    for program in "${dependencies_array[@]}"; do
        if ! command -v "$program" >/dev/null; then
            missing+=("$program")
        fi
    done

    if [[ "${#missing[@]}" -gt 0 ]]; then
        local missing_programs="${missing[*]}"
        notify_user "ERROR" \
            "Missing: $missing_programs" "critical"
        exit 1
    fi
}

is_media_mounted() {
    if [ -d "/media/nim_usb/SILVER" ]; then
        BOOKS_DIR="/media/nim_usb/SILVER"
    elif [ -d "/media/SILVER" ]; then
        BOOKS_DIR="/media/SILVER"
    elif [ -d "/run/media/nisidabay/SILVER" ]; then
        BOOKS_DIR="/run/media/nisidabay/SILVER"
    else
        echo "Error: Book directory not found!" >&2
        return 1
    fi
}

are_books() {
    if [ -n "$(find "$BOOKS_DIR" -type f -name '*.pdf' -print -quit)" ]; then
        return 0
    fi
    notify_user "ERROR" "Missing books" "critical"
    return 1
}

get_books() {
    readarray -t BOOKS_LIST < <(find "$BOOKS_DIR" -type f -name '*.pdf')
    for path in "${BOOKS_LIST[@]}"; do
        file="${path##*/}"
        BOOKS["$file"]="$path"
    done
}

list_books() {
    for book in "${!BOOKS[@]}"; do
        echo "$book"
    done
}

main() {
    check_dependencies "dmenu" "zathura"
    if ! is_media_mounted; then
        exit 1
    fi

    if ! are_books; then
        exit 1
    fi
    get_books
    book=$(list_books | dmenu -c -l 10 "${DMENU_APPEARANCE[@]}" -p "Books")

    if [ -n "$book" ]; then
        zathura "${BOOKS[$book]}" &
    fi
}

main
