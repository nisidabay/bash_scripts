#!/bin/bash
# Author: Carlos Lacaci Moya
# Date: 11/05/20
# Description: Find connected devices on local network

# Create table of devices on the network
arp -a > ips.txt

# Remove parenthesis in line
sed -i 's/[()]//g' ips.txt 

ips=$(awk '{print $2}' ips.txt | sort)

for i in $ips
do

	ping -c 1 $i &> /dev/null &
	if [ $? -eq 0 ] 
	then       
		echo "[+] $i is on line."
		let result+=1
	fi
done

if [[ $result -gt 1 ]]
then
  echo "[#] Devices on local network: $result"
else
  echo No connected devices on the network!
fi

