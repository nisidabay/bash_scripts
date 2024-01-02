#!/usr/bin/bash
# Author: Carlos Lacaci Moya
# Description: Convert mp3 files to wav
# Date: dom 11 dic 2022 09:59:20 CET
# Dependencies: mpg123, sox

# Debugging setup for bash

declare BINARIES_PATH="/usr/bin"
declare _aplay="aplay" 
declare _sox="sox"


function dependencies(){

if [ ! -f "${BINARIES_PATH}/${_aplay}" ]
then
	echo "[!] Missing binary file aplay"
	echo -e "\tUse your distribution package manager to install it"
	exit 1
fi

if [ ! -f "${BINARIES_PATH}/${_sox}" ]
then
	echo "[!] Missing binary file sox"
	echo -e "\tUse your distribution package manager to install it"
    exit 1
fi
}

function count_files(){
    files_no=$(ls  *.mp3 | wc -l)
    if [ "$files_no" = 0 ];then
        echo [!] No mp3 files found here.
        exit 1
    else
        echo "$files_no"
    fi
}

function remove_spaces(){

    for file in *.mp3; do 
        if [[ "$file" = *\ * ]]; then
            mv "$file" "${file// /_}"
        fi
    done

}

function remove_extension(){
    name=$1
    new_name=${name%.mp3}
    echo "$new_name"
}

function rename_file(){
    name=$1
    new_name=${name%.mp3}
    echo new name is: "$new_name"
}

function main(){
dependencies
count_files
remove_spaces


ls *.mp3 |
while read -r FILE;do
	echo -e "⏳Processing $FILE"
    new_name=$(remove_extension "$FILE").wav
	sox "$FILE" "$new_name" 
    echo 
    echo -e "👉 $FILE converted!"
done  

echo
echo -e "🍻 Converted $(count_files) files"
}

main
