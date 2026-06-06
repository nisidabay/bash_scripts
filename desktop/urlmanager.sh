#!/usr/bin/env bash
#
# URL manager with dmenu and ROT13 encoding.
#
# Dependencies: dmenu, xclip or wl-copy, notify-send, browser
# Environment: $HOME, $XDG_CONFIG_HOME

# =============
# HARD CODED WORKING DIR
# =============
WORKING_DIR="$HOME/bin/dmenu"
cd "$WORKING_DIR" || {
    echo "FATAL: Cannot cd to $WORKING_DIR" >&2
    exit 1
}

# =============
# CONFIG (browser only)
# =============
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/urlmanager"
CONFIG_FILE="$CONFIG_DIR/config"
DEFAULT_BROWSER="qutebrowser"

init_config() {
    mkdir -p "$CONFIG_DIR"
    if [[ ! -f "$CONFIG_FILE" ]]; then
        cat >"$CONFIG_FILE" <<EOF
# URL Manager Configuration (v1.3)
# Only BROWSER is configurable.
# Data files are stored in: $WORKING_DIR
# Backups in: $WORKING_DIR/url_backups
BROWSER="$DEFAULT_BROWSER"
EOF
        echo "Default config created at $CONFIG_FILE" >&2
    fi
}

init_config
source "$CONFIG_FILE"
: "${BROWSER:?$CONFIG_FILE missing BROWSER}"

# =============
# FIXED FILE PATHS
# =============
URLS_FILE="encrypted_urls.txt" # ~/bin/dmenu/encrypted_urls.txt
URLS_BACKUP_DIR="url_backups"  # ~/bin/dmenu/url_backups/
BACKUP_FILE="$URLS_FILE.bak"   # ~/bin/dmenu/url_backups/encrypted_urls.txt.bak

# Ensure structure exists
mkdir -p "$URLS_BACKUP_DIR"
[ -f "$URLS_FILE" ] || touch "$URLS_FILE"

# Load dmenu appearance if available
[[ -f "${HOME}/bin/dmenu_wal.sh" ]] && source "${HOME}/bin/dmenu_wal.sh"

# =============
# UTILITIES
# =============

menu() {
    local prompt="$1"
    dmenu -c -i -l 20 "${DMENU_APPEARANCE[@]:-}" -p "$prompt"
}

show_error() {
    notify-send -u critical "URLException: $1" "$2" --icon=dialog-error
}

show_info() {
    notify-send -u normal "URLManager: $1" "$2" --icon=dialog-information
}

check_dependencies() {
    local -a deps=("$@")
    local -a missing=()
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" >/dev/null 2>&1; then
            missing+=("$dep")
        fi
    done
    if [[ ${#missing[@]} -gt 0 ]]; then
        show_error "Missing Dependencies" "Install: ${missing[*]}"
        exit 1
    fi
}

cp2cb() {
    case "${XDG_SESSION_TYPE:-x11}" in
    x11) xclip -selection clipboard ;;
    wayland) wl-copy ;;
    *)
        show_error "Clipboard Error" "Unknown session: $XDG_SESSION_TYPE"
        exit 1
        ;;
    esac
}

cpFromcb() {
    case "${XDG_SESSION_TYPE:-x11}" in
    x11) xclip -o ;;
    wayland) wl-paste ;;
    *)
        show_error "Clipboard Error" "Unknown session: $XDG_SESSION_TYPE"
        exit 1
        ;;
    esac
}

rot13() {
    echo "$1" | tr 'A-Za-z' 'N-ZA-Mn-za-m'
}

check_url() {
    local url="$1"
    if ! [[ "$url" =~ ^https?:// ]]; then
        show_error "Invalid URL" "'$url' is not a valid HTTP/HTTPS URL."
        return 1
    fi
    return 0
}

url_exists() {
    local check_url="$1"
    local line encoded_part decoded
    while IFS= read -r line; do
        encoded_part="${line#*:}"
        decoded=$(rot13 "$encoded_part")
        if [[ "$decoded" == "$check_url" ]]; then
            return 0 # exists
        fi
    done <"$URLS_FILE"
    return 1 # does not exist
}

# =============
# CORE FUNCTIONS
# =============

new_url() {
    local title url encoded_url

    title=$(echo "" | menu 'Enter URL title:')
    [[ -z "$title" ]] && return

    url=$(cpFromcb)
    check_url "$url" || return

    if url_exists "$url"; then
        show_error "Duplicate URL" "This URL is already saved."
        return
    fi

    encoded_url=$(rot13 "$url")
    echo "$title:$encoded_url" >>"$URLS_FILE"
    show_info "Saved" "$title"
}

copy_url() {
    [[ ! -s "$URLS_FILE" ]] && {
        show_error "Empty" "No URLs saved."
        return
    }

    local pick encoded_url decoded_url line
    pick=$(cut -d: -f1 "$URLS_FILE" | menu 'Copy URL:')
    [[ -z "$pick" ]] && return

    while IFS= read -r line; do
        if [[ "$line" == "$pick:"* ]]; then
            encoded_url="${line#"$pick:"}"
            break
        fi
    done <"$URLS_FILE"

    decoded_url=$(rot13 "$encoded_url")
    echo "$decoded_url" | cp2cb
    declare -g copied_url="$decoded_url"
    show_info "Copied" "$pick"
}

browse_url() {
    copy_url
    sleep 0.5
    [[ -n "${copied_url:-}" ]] && {
        $BROWSER "$copied_url" &
        disown
    } || show_error "Failed" "No URL copied."
}

edit_url() {
    [[ ! -s "$URLS_FILE" ]] && {
        show_error "Empty" "No URLs saved."
        return
    }

    local old_title new_title encoded_url line
    old_title=$(cut -d: -f1 "$URLS_FILE" | menu 'Edit title of:')
    [[ -z "$old_title" ]] && return

    new_title=$(echo "$old_title" | menu "New title:")
    [[ -z "$new_title" ]] && return

    while IFS= read -r line; do
        if [[ "$line" == "$old_title:"* ]]; then
            encoded_url="${line#"$old_title:"}"
            break
        fi
    done <"$URLS_FILE"

    sed -i "/^$old_title:/d" "$URLS_FILE"
    echo "$new_title:$encoded_url" >>"$URLS_FILE"
    show_info "Edited" "$new_title"
}

delete_url() {
    [[ ! -s "$URLS_FILE" ]] && {
        show_error "Empty" "No URLs saved."
        return
    }

    local to_delete
    to_delete=$(cut -d: -f1 "$URLS_FILE" | menu 'Delete:')
    [[ -z "$to_delete" ]] && return

    sed -i "/^$to_delete:/d" "$URLS_FILE"
    show_info "Deleted" "$to_delete"
}

backup() {
    if cp -f "$URLS_FILE" "$URLS_BACKUP_DIR/$BACKUP_FILE" 2>/dev/null; then
        show_info "Backup OK" "→ $URLS_BACKUP_DIR/$BACKUP_FILE"
    else
        show_error "Backup Failed" "Could not copy $URLS_FILE"
    fi
}

restore() {
    local backup_path="$URLS_BACKUP_DIR/$BACKUP_FILE"
    [[ ! -f "$backup_path" ]] && {
        show_error "No Backup" "File not found."
        return
    }

    if cp -f "$backup_path" "$URLS_FILE" 2>/dev/null; then
        show_info "Restored" "URLs restored from backup."
    else
        show_error "Restore Failed" "Could not restore from $backup_path"
    fi
}

import_url() {
    local import_file line title url encoded_url
    import_file=$(echo "" | menu 'Path to import file:')
    [[ ! -f "$import_file" ]] && {
        show_error "Not Found" "$import_file"
        return
    }

    local imported=0 skipped=0
    while IFS= read -r line; do
        [[ -z "$line" ]] && continue
        title="${line%%:*}"
        url="${line#*:}"
        url="${url#"${url%%[![:space:]]*}"}" # trim leading
        url="${url%"${url##*[![:space:]]}"}" # trim trailing

        if [[ -z "$title" ]] || [[ -z "$url" ]]; then
            ((skipped++))
            continue
        fi

        if ! check_url "$url" 2>/dev/null; then
            ((skipped++))
            continue
        fi

        if url_exists "$url"; then
            ((skipped++))
            continue
        fi

        encoded_url=$(rot13 "$url")
        echo "$title:$encoded_url" >>"$URLS_FILE"
        ((imported++))
    done <"$import_file"

    show_info "Import Complete" "Imported: $imported | Skipped: $skipped"
}

show_help() {
    cat <<'EOF' | menu 'Help - Press Enter to Close'
URL Manager v1.0 - Help
=======================
ROT13 is used for OBFUSCATION only — NOT real encryption.

Storage:
  Main file: ~/bin/dmenu/encrypted_urls.txt
  Backups:   ~/bin/dmenu/url_backups/

Menu Options:
  Backup     → Save backup to ~/bin/dmenu/url_backups/
  Browse URL → Copy & open in browser
  Copy URL   → Copy saved URL to clipboard
  Delete URL → Remove URL from list
  Edit URL   → Rename title of saved URL
  Help       → Show this message
  Import URL → Import from file (format: title:url)
  New URL    → Add URL from clipboard with custom title
  Quit       → Exit
  Restore    → Restore from last backup

Config: ~/.config/urlmanager/config (browser only)
EOF
}

main() {
    check_dependencies "dmenu" "notify-send" "$BROWSER"
    [[ "$XDG_SESSION_TYPE" == "x11" ]] && check_dependencies "xclip"
    [[ "$XDG_SESSION_TYPE" == "wayland" ]] && check_dependencies "wl-copy" "wl-paste"

    local choice
    choice=$(printf 'Backup URLs\nBrowse URL\nCopy URL\nDelete URL\nEdit URL\nHelp\nImport URL\nNew URL\nRestore URLs\nQuit' | menu 'URL Manager:')

    case "$choice" in
    'Backup URLs') backup ;;
    'Browse URL') browse_url ;;
    'Copy URL') copy_url ;;
    'Delete URL') delete_url ;;
    'Edit URL') edit_url ;;
    'Help') show_help ;;
    'Import URL') import_url ;;
    'New URL') new_url ;;
    'Restore URLs') restore ;;
    'Quit') exit 0 ;;
    '') exit 0 ;; # Esc or empty
    *) show_error "Invalid" "Unknown option: $choice" ;;
    esac
}

main
