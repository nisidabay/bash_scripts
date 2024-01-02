#!/bin/sh

echo "Introduce la extension del fichero a descargar ( jpg,html ) "
read extension
if [ ! -z "$extension" ];then
	echo "Introduce la URL ( http://www.oreilly.com )"
	read url
fi	

if [ ! -z "$url" ];then
	lynx -dump "$url" | grep "$extension" | awk '{print $2}' > urllist.txt

fi

if [ ! -z "urllist.txt" ];then

	for x in $(cat urllist.txt)
	do
		wget -nc -m -t3 $x

	done	
fi	
