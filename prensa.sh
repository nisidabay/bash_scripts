# Abre una serie de urls de un fichero de texto.
# Carlos Lacaci 2019
#!/bin/bash

URLS="prensa.txt"
VIVALDI=$(which vivaldi)

if [ -s $URLS ]
then
	echo "[+] Trabajando con el archivo: $URLS"
else
 	echo "[-] Archivo $URLS no existe"
	exit 1
fi

if [ $? -eq 0 ]
then
	echo "[+] Vivaldi instalado"
	for link in $(cat $URLS)
	do
		echo "[+] Abriendo página: $link"
	       	$VIVALDI -new-tab $link &>/dev/null &

	done
else
	echo "[-] Vivaldi no instalado"
	exit 1
fi
