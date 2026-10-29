#!/usr/bin/env bash
#
# Create a list of unhidden folders in HOME.
#
# Dependencies: find, tee

find "$HOME" -type d -not -path '*/\.*' -print 2>/dev/null |
    tee folders.txt
