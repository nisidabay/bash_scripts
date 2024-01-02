#!/usr/bin/bash
#
# Validate telephone numbers

ValidPhone(){

validnumber=$(echo "$1" | sed -e 's/^⁻ [[:digit:]\(\)]//g')

if [ "$validnumber" = "$1" ];then # no changes made so it's valid
    return 0
else
    return 1
fi
}
echo -n "Enter a phone number: "
read number

if ! ValidPhone "$number";then
    echo "Not a valid phone number" >&2
    exit 1
else
    echo "Valid number"
fi
exit 0



