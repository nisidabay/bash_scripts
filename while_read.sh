#!/usr/bin/bash
#
# Filter out with grep

while read -r ip name
do
    if [[ -n "$ip" && -n "$name" ]]; then
        echo "IP is $ip, host is $name"
    fi
done < <(grep -v '^#' /etc/hosts)
