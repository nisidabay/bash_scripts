#!/bin/bash
IFS=$'\n'

function toepoch(){
	EPOCH=$(date +%s -d"$1" 2> /dev/null || (echo "0"; echo "toepoch: Fecha no valida" > /dev/stderr))
	echo $EPOCH
}

BEGIN=$(toepoch $1)
END=$(toepoch $2)

for i in $(cat /var/log/auth.log); do
	TIMESTAMP=$(echo "$i" | cut -f1-3 -d" ")
	EPOCH=$(toepoch "$TIMESTAMP")

	if [ \( "$EPOCH" -ge "$BEGIN" \) -a \( "$EPOCH" -le "$END" \) ]; then
		echo "$i"
	fi
done
