#!/bin/bash


if [ ! -d /tmp/cd_wd ]; then
	mkdir /tmp/cd_wd
else
	rm -rf /tmp/cd_wd/*
fi


TRACK=1
ls *.mp3 |
while read FILE;do
	mpg123 -s "$FILE" | sox -t raw -r 44100 -w -s -c 2 - /tmp/cd_wd/trak_$TRACK.wav
	TRACK=`expr $TRACK + 1`
done

ls *.Mp3 |
while rea FILE; do
	mpg123 -s "$FILE" | sox -t raw -r 44100 -w -s -c 2 - /tmp/cd_wd/trak_$TRACK.wav
	TRACK=`expr $TRACK + 1`
done

cdrecord -v -dev=3,0 speed=4 -audio -pad -fix /tmp/cd_wd/trak_*.wav

