#!/bin/bash
# Create a number of text files and add
# information to them

function create_files(){	
	for ((i=1; i<=$1; i++))
	do
		touch "File"$i".txt"
	done
	echo $1 archivos creados
}

read -p "Número de archivos quieres crear: " NUM 
create_files $NUM

# Add information to the files
for FILE in $(ls File*.txt)
do
	echo  $(date) >> $FILE
done
