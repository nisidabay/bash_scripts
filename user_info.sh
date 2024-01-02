#!/bin/bash 
# Author: Carlos Lacaci Moya
# Date: 11/05/20
# Description: Find users with account on the system

read -p "Enter the user login: " LOGIN

cat /etc/passwd | grep $LOGIN > /dev/null

if [ $? -eq 0 ]
then
	echo "[+] Found user: $LOGIN"
	
	cat /etc/passwd | awk 'BEGIN{FS=":"} /'"$LOGIN"'/ {print $1, $5, $6, $7}'
else
	echo "[-] User not found!"
fi
