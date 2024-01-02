#!/usr/bin/bash
#
# Create a list of unhidden folders in $HOME
#

find "$HOME" -type d -not -path "*/\.*" -print 2> /dev/null |
    tee folders.txt
