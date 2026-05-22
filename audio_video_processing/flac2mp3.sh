#!/usr/bin/env bash
#
# Convert FLAC files to MP3.
#
# Dependencies: ffmpeg

IFS=$'\n'
for i in *.flac; do
    ffmpeg -i "$i" -acodec libmp3lame "$(basename "${i/.flac/}").mp3"
    sleep 60
done
