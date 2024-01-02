#!/bin/sh
#
#Convert upper-case to lower-case files

for file in *.test
do
    lcase=$(echo "$file" | tr '[A-Z' '[:lower:]')
    # If lower case already skip
	[ -f "$lcase" ] && continue

	[ "$file" != "$lcase" ]

	mv "$file" "$lcase"
done 	
