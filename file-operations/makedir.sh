#!/usr/bin/env bash
#
# Make directory with custom permissions.
#
# Dependencies: mkdir

_mkdir() {
    USAGE="Usage: makedir 'dirname' [octal:permission]"
    local d="$1"
    local p=${2:-0755}

    [ $# -eq 0 ] && {
        echo $USAGE
        exit 1
    }

    [ ! -d "$d" ] && mkdir -v -m "$p" -p "$d"
}

_mkdir $@
