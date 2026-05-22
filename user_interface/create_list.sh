#!/usr/bin/env bash
#
# List ASCII files in current directory.
#
# Dependencies: file

for f in *; do
    if [[ $(file "$f") =~ "ASCII" ]]; then
        echo "$f"
    fi
done
