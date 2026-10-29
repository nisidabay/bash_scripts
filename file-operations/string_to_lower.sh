#!/usr/bin/env bash
#
# Convert string to lowercase.
#
# Dependencies: tr

to_lower() {
    input="$1"
    echo "$input" | tr '[:upper:]' '[:lower:]'
}

while true; do
    echo -n "Enter c to continue: "
    read -sn1 REPLY
    REPLY="$(to_lower "$REPLY")"
    if [ "$REPLY" = "" ]; then
        break
    fi
done
echo "Finished"

result=$(to_lower "TEST")
echo "$result"
