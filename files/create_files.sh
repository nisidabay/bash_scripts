#!/usr/bin/env bash
#
# Create a number of files specified by the user.
#
# Dependencies: touch, seq

echo [+] Write the name of the file:
read f

echo [+] Write the number of files to create:
read n

for i in $(seq 01 $n); do
    echo Creating file $i-$f
    touch $i-$f
done
