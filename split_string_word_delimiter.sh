#!/usr/bin/bash
#
# Split a string with multi-character delimiter
declare -a myarray

#Define the string to split
text="learnHTMLlearnPHPlearnMySQLlearnJavascript"

#Define multi-character delimiter
delimiter="learn"
#
#Concatenate the delimiter with the main string
string=$text$delimiter

echo This is the original string: "$string"
#Split the text based on the delimiter
while [[ $string ]]; do
  myarray+=( "${string%%"$delimiter"*}" )
  sleep 1
  echo This is the array: "${myarray[@]}"
  string=${string#*"$delimiter"}
  sleep 1
  echo This is the string: "$string"
done

#Print the words after the split
for value in "${myarray[@]}"
do
  echo Values in the array: "$value "
done
printf "\n"

#-------------------------------------
# Remove the sleep and unnecessary echos
