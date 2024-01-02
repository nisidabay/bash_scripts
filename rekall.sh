#!/bin/bash
#Script que cada cierto tiempo para ver si hay comunicacion

SLEEP=10s

if [ -e "/var/run/ppp0.pid" ]; then 
	echo " * * *	PPP-UP is running * * * "
else
	echo " * * *	PPP0 interface is not up! * * * "
	exit 1
fi

while [ -e "/var/run/ppp0.pid" ]; 
do
	ping -c 1 "$HOST" > /dev/null
	echo " * * *	PPP-UP is running * * * "
	clear
	sleep $SLEEP
done
exit 0
  












