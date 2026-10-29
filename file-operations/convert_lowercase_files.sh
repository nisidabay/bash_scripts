#!/usr/bin/env bash
#
# Convert upper-case file names to lower-case.
#
# Dependencies: tr, mv

for file in *.test; do
    lcase=$(echo "$file" | tr '[:upper:]' '[:lower:]')
    [ -f "$lcase" ] && continue

    [ "$file" != "$lcase" ]

    mv "$file" "$lcase"
done
