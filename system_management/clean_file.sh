#!/usr/local/bin/bash
#
# Remove coments and empty lines. Create a copy of the file

function clean_file() {
    sed -i.bak '/^\s*#/d;/^$/d' "$1"
}
