#!/bin/bash

#Script 4 backup files

#Directory 4 saving the files
DIR="/floppy"

#copy a file in the backup directory and append the date.
cp "$1" "$DIR/$1.$(date +%d%h%y)"

#inserting a blank line at the end of the file
echo " " >> "$DIR/$1.$(date +%d%h%y)"

#and inserting a comment
echo "#>> '$(pwd)'/$1 copied over on '$(date)' $DIR/$1.'(date+%d%h%y)'"

#all is done
echo "Made a backup of $1"

