#!/usr/bin/env bash
#
# Remove comments and empty lines from a file.
#
# Dependencies: sed

function clean_file() {
    sed -i.bak '/^\s*#/d;/^$/d' "$1"
}
