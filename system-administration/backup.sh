#!/usr/bin/env bash
#
# Backup a file with timestamp.
#
# Dependencies: none
#

# Directory for saving the files
DIR="/floppy"

# Copy a file in the backup directory and append the date.
cp "$1" "$DIR/$1.$(date +%d%h%y)"

# Inserting a blank line at the end of the file
echo " " >>"$DIR/$1.$(date +%d%h%y)"

# And inserting a comment
echo "#>> '$(pwd)'/$1 copied over on '$(date)' $DIR/$1.'(date+%d%h%y)'"

# All is done
echo "Made a backup of $1"
