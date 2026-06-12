#!/usr/bin/env bash
#
# Reference: split a string into an array — 5 methods.
#
# Dependencies: bash, tr
#
# Each method is self-contained. Run this script directly to see all
# examples in action, or source individual functions for reuse.

set -euo pipefail

separator() {
    printf '%*s\n' "${COLUMNS:-80}" '' | tr ' ' '─'
}

# ── Method 1: IFS + read -a (single character delimiter) ──────────
method_ifs_read() {
    local text="$1"
    local delim="${2:-:}"
    local OLDIFS="$IFS"
    IFS="$delim"
    read -ra parts <<<"$text"
    IFS="$OLDIFS"
    echo "${parts[@]}"
}

# ── Method 2: readarray -d (Bash ≥4.4, single character) ─────────
method_readarray() {
    local text="$1"
    local delim="${2:-:}"
    local parts=()
    readarray -d "$delim" -t parts <<<"$text"
    echo "${parts[@]}"
}

# ── Method 3: IFS + read -a (space delimiter) ─────────────────────
method_ifs_space() {
    local text="$1"
    local parts=()
    read -ra parts <<<"$text"
    echo "${parts[@]}"
}

# ── Method 4: tr (single character → newline, then array) ─────────
method_tr() {
    local text="$1"
    local delim="${2:- }"
    local parts=()
    parts=($(echo "$text" | tr "$delim" '\n'))
    echo "${parts[@]}"
}

# ── Method 5: parameter expansion (multi-character delimiter) ─────
method_param_expansion() {
    local text="$1"
    local delim="$2"
    local parts=()
    local tmp="${text}${delim}"
    while [[ "$tmp" ]]; do
        parts+=("${tmp%%"$delim"*}")
        tmp="${tmp#*"$delim"}"
    done
    echo "${parts[@]}"
}

# ── Demo ──────────────────────────────────────────────────────────
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    echo
    echo "  Split String — 5 Methods"
    echo "  Reference: files/split_string.sh"
    echo

    separator
    echo "1) IFS + read -a     (colon delimiter)"
    echo "   Input: 'a:b:c'"
    echo "   Output: $(method_ifs_read 'a:b:c' ':')"
    echo

    separator
    echo "2) readarray -d      (colon delimiter, Bash ≥4.4)"
    echo "   Input: 'a:b:c'"
    echo "   Output: $(method_readarray 'a:b:c' ':')"
    echo

    separator
    echo "3) IFS + read -a     (space delimiter, default)"
    echo "   Input: 'hello bash world'"
    echo "   Output: $(method_ifs_space 'hello bash world')"
    echo

    separator
    echo "4) tr                (space → newline)"
    echo "   Input: 'hello bash world'"
    echo "   Output: $(method_tr 'hello bash world' ' ')"
    echo

    separator
    echo "5) Parameter expansion (multi-char delimiter 'learn')"
    echo "   Input: 'learnXlearnYlearnZ'"
    echo "   Output: $(method_param_expansion 'learnXlearnYlearnZ' 'learn')"
    echo

    separator
    echo "  Tip: source this file and call any method_* function"
    echo "  directly in your own scripts."
    echo
fi
