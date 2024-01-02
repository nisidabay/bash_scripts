#Script para cerrar la conexion a internet
#Carlos Lacaci Moya 13.06.00
#------------------------------------------

#!/bin/bash

#El campo 5 del archivo messages me da el numero de pid
#pero en la forma pppd[999]:
#El "Serial connection" es la cadena que identifica a la
#conexion cuando se realiza

tempid=$(awk '/Serial connection/ { print $5 }' \
/var/log/messages | tail -1)

#Tengo que dejar solo el numero de pid
#por lo que empiezo quitando pppd[

tempid2=${tempid##pppd[}

#Por ultimo quito ]: y obtengo el numero del pid

numpid=${tempid2%%]:}

#Compruebo que realmente hay una conexion a internet

if [ -e "/var/run/ppp0.pid" ]; then
	kill -INT "$numpid"
	clear
	echo	
	echo "-----------------------------"
    echo "Conexion a internet terminada"
    echo "-----------------------------"
    echo
    echo -n "Log de desconexion: "
    awk '/Exit/ { print $0 }' /var/log/messages | tail -1 
else
	clear
	echo
	echo "++++++++++++++++++++++++++"
	echo "No hay conexion a internet"
	echo "++++++++++++++++++++++++++"
	echo
fi
