#!/usr/bin/bash
# Carlos Lacaci 2019
# Realiza una busqueda en google

BROWSER="firefox"
if command -v $BROWSER;then
	echo "[+] firefox instalado"
else
	echo "[-] firefox no instalado"
	exit 1
fi

read -r -p "Enter the text to find and browse: " text

"$BROWSER" -new-tab https://www.google.es/search?q="$text" > /dev/null
