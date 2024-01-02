#!/bin/bash

# Author: Carlos Lacaci Moya
# Descripción: Comprueba usuarios en un sistema antes de 
# asignarles una carpeta en /home
# Fecha: 09/05/2020


echo [+] This script will find users with home folder in the system
cd /home
for DIR in *
do
	echo [+] Find user: $DIR
	check=$(grep -c $DIR /etc/passwd)
	if [ $check -ge 1 ]
	then
		echo [!] $DIR exists already
	else
		echo [+] $DIR can be assigned
	fi
done
