#!/usr/bin/bash
function trapint(){
echo "Interruption in [${BASH_SOURCE[1]}] at line [${BASH_LINENO[0]}"]
exit 1
}

trap trapint SIGINT

for i in $(seq 1 100); do
    echo "$i"
    sleep 0.5
done
