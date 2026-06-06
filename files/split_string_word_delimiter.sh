#!/usr/bin/env bash
#
# Split a string with multi-character delimiter.
#
# Dependencies: bash

declare -a myarray

text="learnHTMLlearnPHPlearnMySQLlearnJavascript"

delimiter="learn"

string=$text$delimiter

echo This is the original string: "$string"

while [[ $string ]]; do
    myarray+=("${string%%"$delimiter"*}")
    sleep 1
    echo This is the array: "${myarray[@]}"
    string=${string#*"$delimiter"}
    sleep 1
    echo This is the string: "$string"
done

for value in "${myarray[@]}"; do
    echo Values in the array: "$value "
done
printf "\n"
