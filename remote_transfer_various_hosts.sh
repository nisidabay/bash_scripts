#!/bin/bash
# Autor: Carlos Lacaci Moya
# Descripción: Transfiere archivos por scp
# Fecha: 07/05/20

function Fedora(){
	for i in $@
	do
		ping -c 1 192.168.1.108 &>/dev/null
		if [ "$?" -eq "0" ]
		then
			if [ -n $i ] 
			then
			
			echo [+] Transfiriendo archivo [$i] a Fedora
			sshpass -p 'PASSWORD_REMOVED' scp $i Fedora@192.168.1.108:/home/nisidabay
			fi
		else
			echo "[-] No hay archivos para copiar o Fedora no está en línea"
			exit 1
            echo $i
		fi
	done

}

function Pi(){
	for i in $@
	do

		ping -c 1 192.168.1.100 &>/dev/null
		if [ "$?" -eq "0" ]
		then
			if [ -n $i ] 
			then
			
			echo [+] Transfiriendo archivo [$i] a pi
			sshpass -p 'PASSWORD_REMOVED' scp $i pi@192.168.1.100:/home/pi
			fi
		else
			echo "[-] No hay archivos para copiar o pi no está en línea"
			exit 1
		fi
	done
}


if [ $# -eq 0 ]
then

	echo "[+] Uso: remote_transfer.sh [files | *files*]"
	exit 1
else

	echo "[+] Uso: remote_transfer.sh [files | *files*]"
	read -n 1 -p "[+] Introduce el host [(F)edora .108, (P)i . 100]: " H
	echo
fi

case $H in
	F|f*)
		Fedora $@;;
	P|p*)
		Pi $@;;
	*)
		echo "Host desconocido";;

esac		


