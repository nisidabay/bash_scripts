#!/bin/sh
#Script para pasar de mp3 a wav y despues grabarlo a cd. Si quieres ;)

#Variable que servira para numerar las pistas de audio

declare -i number=1

#Me situo en el directorio de los mp3...

ls *.mp3 |
while read FILE;do
	echo "== $FILE =="
	mpg123 -s "$FILE" | sox -t raw -r 44100 -w -s -c 2 - track$number.wav
	number=number+1 
done  

ls *.Mp3 |
while read FILE;do
	echo "== $FILE =="
	mpg123 -s "$FILE" | sox -t raw -r 44100 -w -s -c 2 - track$number.wav
	number=number+1 
done  

# Me pongo a rezar...
cdrecord -v -dev=3,0 speed=4 -dummy -audio -pad -swab -fix track*.wav

#Borro los archivos wav y mp3 que quedaron sueltos y expulso el cd
rm -rf *.wav
rm -rf *.mp3
rm -rf *.MP3
eject	
