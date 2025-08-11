#!/bin/bash
# Controla los pcs online de la red local

hosts="ip_list.txt" 

if [ -s $host ]
then
	echo "[+] Archivo de hosts encontrado"
else
	echo "[-] Archivo de hosts no encontrado"
	exit 1
fi

for pc in $(cat $hosts)
do
	ping -c1 $pc &>/dev/null
	#echo $?
	if [ $? -eq 0 ]
	then
		echo "[+] Host $pc on line"
	else
		echo "[-] Host $pc unreachable"
	fi
done
	



