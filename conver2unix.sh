#!/bin/sh

for x
	do
		echo "Converting to Unix $x"
		tr '\015' '\012' < "$x" > "tmp.$x"
		mv "tmp.$x" "$x"
	done		
