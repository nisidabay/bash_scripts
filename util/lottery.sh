#!/usr/bin/env bash
#
# Generate random numbers with awk.
#
# Dependencies: awk, date

header_separator() {
    _date=$(date)
    header="Logging started at $_date"

    if [[ $# -gt 0 && $1 == "end" ]]; then
        header="Logging ended at $_date"
    fi

    separator_length=${#header}
    separator=$(printf '%*s' "$separator_length" | tr ' ' '-')

    printf "%s\n%s\n" "$header" "$separator"
}

header_separator
echo "Lotery numbers"
awk 'BEGIN{srand; for (i=1;i<=6;i++)print int(50 * rand())}'
header_separator "end"
