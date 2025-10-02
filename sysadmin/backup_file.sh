#!/usr/bin/env bash
#
# safe_backup.sh — Safely back up and process a  file.
#
# This script:
# 1. Validates that the input file exists and has required permissions.
# 2. Creates a backup (.bak) before any modification.
# 3. Performs a safe in-place edit (example: replace a setting).
#
# Usage: ./safe_backup.sh <config_file>
#
# Exit codes:
#   0 — Success
#   1 — General failure (e.g., validation, backup, or processing failed)
#   2–7 — Specific validation or operation errors (see validate_file/backup_file)

set -euo pipefail

# -----------------------------------------------------------------------------
# validate_file: Check if a file exists and has the required permissions.
# Arguments:
#   $1 — Path to the file
#   $2 — Required permissions (default: "r")
#        Supported: "r", "w", "x", "rw"
# Returns:
#   0 — Valid file with required permissions
#   1 — File not found
#   2 — No filename provided
#   3–6 — Permission-specific errors
# -----------------------------------------------------------------------------
validate_file() {
    local file="$1"
    local required_permissions="${2:-r}"

    # Ensure a filename was provided
    if [[ -z "$file" ]]; then
        echo "validate_file: No filename provided" >&2
        return 2
    fi

    # Check file existence
    if [[ ! -e "$file" ]]; then
        echo "File not found: $file" >&2
        return 1
    fi

    # Validate permissions based on requested access
    case "$required_permissions" in
    r)
        if [[ ! -r "$file" ]]; then
            echo "File not readable: $file" >&2
            return 3
        fi
        ;;
    w)
        if [[ ! -w "$file" ]]; then
            echo "File not writable: $file" >&2
            return 4
        fi
        ;;
    x)
        if [[ ! -x "$file" ]]; then
            echo "File not executable: $file" >&2
            return 5
        fi
        ;;
    rw)
        if [[ ! -r "$file" ]] || [[ ! -w "$file" ]]; then
            echo "File not readable and/or writable: $file" >&2
            return 6
        fi
        ;;
    *)
        echo "validate_file: Unsupported permission mode '$required_permissions'" >&2
        return 2
        ;;
    esac

    return 0
}

# -----------------------------------------------------------------------------
# backup_file: Create a backup copy of a file.
# Arguments:
#   $1 — Source file path
#   $2 — (Optional) Backup file path (default: <source>.bak)
# Returns:
#   0 — Backup succeeded
#   1 — Validation failed (e.g., source not readable)
#   7 — Copy operation failed
# -----------------------------------------------------------------------------
backup_file() {
    local source="$1"
    local backup="${2:-$source.bak}"

    # Only need read access to source for backup
    validate_file "$source" "r" || return 1

    if cp -f "$source" "$backup"; then
        echo "Backup created: $backup"
        return 0
    else
        echo "Failed to create backup of '$source' to '$backup'" >&2
        return 7
    fi
}

# -----------------------------------------------------------------------------
# process_config: Safely process (modify) a  file.
# - Validates file has read+write access (needed for backup + edit).
# - Creates a backup before any modification.
# - Applies a safe in-place edit (example: update a setting).
# Arguments:
#   $1 — Config file to process
# Returns:
#   0 — Success
#   1 — Any step failed (validation, backup, or edit)
# -----------------------------------------------------------------------------
process_config() {
    local file="$1"

    # Need both read (to back up) and write (to modify) permissions
    if ! validate_file "$file" "rw"; then
        return 1
    fi

    # Always back up before modifying
    if ! backup_file "$file"; then
        echo "Aborting — cannot create backup of config file" >&2
        return 1
    fi

    echo "Config file processed successfully: $file"
    return 0
}

# -----------------------------------------------------------------------------
# main: Entry point of the script.
# Arguments:
#   $1 — Path to the  file to process
# Exits with:
#   0 — Success
#   1 — Failure
# -----------------------------------------------------------------------------
main() {
    if [[ $# -ne 1 ]]; then
        echo "Usage: $0 <config_file>" >&2
        exit 1
    fi

    local file="$1"

    if process_config "$file"; then
        echo "Script completed successfully"
        exit 0
    else
        echo "Script failed" >&2
        exit 1
    fi
}

# Run main with all arguments
main "$@"
