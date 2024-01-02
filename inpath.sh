#!/usr/bin/bash

#########################################################
# Name: inpath.sh
#
# Purpose: Verified that a program is either valid
# or can be found in the PATH directory list
#
# Author: Wicked Cool Shell Scripts 101 Scripts for Linux
#
# Date: sáb 29 may 2021 08:57:55 CEST
#########################################################

set -euo pipefail

function in_path()
{
# Given a command and the PATH, tries to find the command. Returns 0 if 
# found and executable; 1 if not. Note thas this temporarily modifies
# the IFS (internal field separator) but restores it upon completion.

cmd=$1	path=$2	result=1
oldIFS=$IFS IFS=":"

for directory in ${path}
do
	if [ -x "$directory/$cmd" ]; then
		result=0
	fi
done

IFS=$oldIFS
return $result
} 
 
# Main Entry 
function checkForCmdInPath() 
{ 
# Ensures the arguments are valid commands 
var=$1

if [ -n "$var" ]; then
	
	if ! in_path "$var" "$PATH"; then
		return 1
	fi
fi  
}  

function usage()
{
echo "Usage: $0 command" >&2
exit 1
}  

if [ $# -ne 1 ]; then
	usage
fi

# Main menu
checkForCmdInPath "$1"
case $? in
    0) echo "$1 found in PATH" 
    exit 0 ;;
    1) echo "$1 not found in PATH"
    exit 1 ;;
esac

