#!/bin/bash

read -p "Introduce tu edad: " EDAD
MAYOR=18

if [ $EDAD -lt $MAYOR ]; then
	echo "No puedes votar"
else
	echo "Puedes votar"
fi	
