#!/usr/bin/env bash
#
# Create file backups with timestamps.
#
# Dependencies: none

set -euo pipefail
trap 'handle_error $LINENO' ERR

handle_error() {
    echo "Error: Command failed at line $1" >&2
    exit 1
}

fatal() {
    echo "FATAL: $1" >&2
    exit "${2:-1}"
}

create_backup() {
    local source="$1"
    local destination="${2:-.}"
    local timestamp
    timestamp=$(date +%Y%m%d_%H%M%S)

    if [[ -z "$source" ]]; then
        echo "Error: Source path required" >&2
        return 1
    fi

    if [[ ! -e "$source" ]]; then
        echo "Error: Source not found: ${source}" >&2
        return 1
    fi

    local name="${source##*/}"
    local backup_name="${name}_${timestamp}.tar.gz"
    local backup_path="${destination}/${backup_name}"

    echo "Creating backup of ${source}..."
    echo "Destination: ${backup_path}"

    if tar -czf "$backup_path" -C "$(dirname "$source")" "$(basename "$source")" 2>/dev/null; then
        local size
        size=$(stat -c%s "$backup_path" 2>/dev/null || echo "0")
        echo "Backup created successfully!"
        echo "Size: ${size} bytes"
        echo "Path: ${backup_path}"
    else
        fatal "Backup failed"
    fi
    echo ""
}

list_backups() {
    local backup_dir="${1:-.}"
    local pattern="${2:-*.tar.gz}"

    if [[ ! -d "$backup_dir" ]]; then
        echo "Error: Directory not found: ${backup_dir}" >&2
        return 1
    fi

    echo "=== Backups in ${backup_dir} ==="

    local count=0
    local total_size=0

    for backup in "$backup_dir"/$pattern; do
        [[ -f "$backup" ]] || continue
        ((count++)) || true

        local size
        size=$(stat -c%s "$backup" 2>/dev/null || echo "0")
        total_size=$((total_size + size))

        local name="${backup##*/}"
        local mtime
        mtime=$(stat -c "%y" "$backup" 2>/dev/null | cut -d' ' -f1)

        local size_display
        if [[ "$size" -lt 1024 ]]; then
            size_display="${size} B"
        elif [[ "$size" -lt 1048576 ]]; then
            size_display="$((size / 1024)) KB"
        else
            size_display="$((size / 1048576)) MB"
        fi

        echo "${mtime} ${size_display} ${name}"
    done

    local total_display
    if [[ "$total_size" -lt 1048576 ]]; then
        total_display="$((total_size / 1024)) KB"
    else
        total_display="$((total_size / 1048576)) MB"
    fi

    echo ""
    echo "Total: ${count} backup(s), ${total_display}"
    echo ""
}

restore_backup() {
    local backup_file="$1"
    local restore_dir="${2:-.}"

    if [[ ! -f "$backup_file" ]]; then
        echo "Error: Backup file not found: ${backup_file}" >&2
        return 1
    fi

    echo "Restoring backup: ${backup_file##*/}"
    echo "Restore directory: ${restore_dir}"

    if tar -xzf "$backup_file" -C "$restore_dir" 2>/dev/null; then
        echo "Restore completed successfully!"
    else
        fatal "Restore failed"
    fi
    echo ""
}

clean_old_backups() {
    local backup_dir="${1:-.}"
    local days="${2:-7}"
    local pattern="${3:-*.tar.gz}"

    if [[ ! -d "$backup_dir" ]]; then
        echo "Error: Directory not found: ${backup_dir}" >&2
        return 1
    fi

    if ! [[ "$days" =~ ^[0-9]+$ ]]; then
        echo "Error: Invalid days: ${days}" >&2
        return 1
    fi

    echo "=== Cleaning backups older than ${days} days ==="

    local now
    now=$(date +%s)
    local deleted=0

    for backup in "$backup_dir"/$pattern; do
        [[ -f "$backup" ]] || continue

        local mtime
        mtime=$(stat -c "%Y" "$backup" 2>/dev/null)
        [[ -n "$mtime" ]] || continue

        local age_days=$(((now - mtime) / 86400))

        if [[ "$age_days" -gt "$days" ]]; then
            local name="${backup##*/}"
            rm -f "$backup"
            echo "Deleted: ${name} (${age_days} days old)"
            ((deleted++)) || true
        fi
    done

    echo "Deleted: ${deleted} backup(s)"
    echo ""
}

backup_status() {
    local backup_dir="${1:-.}"

    if [[ ! -d "$backup_dir" ]]; then
        echo "Error: Directory not found: ${backup_dir}" >&2
        return 1
    fi

    echo "=== Backup Status: ${backup_dir} ==="

    local count=0
    local newest=""
    local newest_time=0
    local oldest=""
    local oldest_time=0
    local total_size=0

    for backup in "$backup_dir"/*.tar.gz; do
        [[ -f "$backup" ]] || continue
        ((count++)) || true

        local mtime
        mtime=$(stat -c "%Y" "$backup" 2>/dev/null)
        [[ -n "$mtime" ]] || continue

        if [[ "$mtime" -gt "$newest_time" ]] || [[ "$newest_time" -eq 0 ]]; then
            newest_time=$mtime
            newest="${backup##*/}"
        fi

        if [[ "$oldest_time" -eq 0 ]] || [[ "$mtime" -lt "$oldest_time" ]]; then
            oldest_time=$mtime
            oldest="${backup##*/}"
        fi

        local size
        size=$(stat -c%s "$backup" 2>/dev/null || echo "0")
        total_size=$((total_size + size))
    done

    if [[ "$count" -eq 0 ]]; then
        echo "No backups found"
    else
        echo "Total backups: ${count}"

        if [[ -n "$newest" ]]; then
            local newest_display
            newest_display=$(date -d "@$newest_time" "+%Y-%m-%d %H:%M:%S")
            echo "Newest: ${newest} (${newest_display})"
        fi

        if [[ -n "$oldest" ]]; then
            local oldest_display
            oldest_display=$(date -d "@$oldest_time" "+%Y-%m-%d %H:%M:%S")
            echo "Oldest: ${oldest} (${oldest_display})"
        fi

        local total_display
        if [[ "$total_size" -lt 1048576 ]]; then
            total_display="$((total_size / 1024)) KB"
        else
            total_display="$((total_size / 1048576)) MB"
        fi
        echo "Total size: ${total_display}"
    fi
    echo ""
}

main() {
    local command="${1:-}"
    local arg1="${2:-.}"
    local arg2="${3:-}"
    local arg3="${4:-}"

    case "$command" in
    create)
        create_backup "$arg1" "${arg2:-.}"
        ;;
    list)
        list_backups "$arg1" "${arg2:-*.tar.gz}"
        ;;
    restore)
        restore_backup "$arg1" "${arg2:-.}"
        ;;
    clean)
        clean_old_backups "$arg1" "${arg2:-7}" "${arg3:-*.tar.gz}"
        ;;
    status)
        backup_status "$arg1"
        ;;
    *)
        echo "Usage: $0 {create|list|restore|clean|status} [args]"
        echo ""
        echo "Commands:"
        echo "  create <source> [dest]     - Create backup of file/directory"
        echo "  list [dir] [pattern]       - List backups"
        echo "  restore <backup> [dir]     - Restore from backup"
        echo "  clean [dir] [days]         - Delete backups older than N days"
        echo "  status [dir]               - Show backup status"
        ;;
    esac
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
