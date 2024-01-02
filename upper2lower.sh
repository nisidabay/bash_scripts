#!/usr/bin/bash

#Convert upper-case to lower-case

for file in *.test
do
	lcase=`echo "$file" | tr '[A-Z' '[a-z]'`
	[ -f "$lcase" ] && continue

	[ "$file" != "$lcase" ]

	mv "$file" "$lcase"
done 	
