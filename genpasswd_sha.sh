#!/usr/bin/bash

##################################################
# Name:
#
# Purpose: generate a random password
#
# Author:
#
# Date:
#
# Code from:https://www.golinuxcloud.com/bash-getopts/
#
# Modified by:
## On Date Date:
#
# Actions taken:
#
# [+]
# [-]
################################################## 
function usage {
        echo "Usage: $(basename $0) [-vs] [-l LENGTH]" 2>&1
        echo 'Generate a random password.'
        echo '   -l LENGTH   Specify the password length'
        echo '   -s          Append a special character to the password.'
        echo '   -v          Increase verbosity.'
        exit 1
}

function print_out {
   local MESSAGE="${@}"
   if [[ "${VERBOSE}" == true ]];then
      echo "${MESSAGE}"
   fi
}


# if no input argument found, exit the script with usage
if [[ ${#} -eq 0 ]]; then
   usage
fi


# Define list of arguments expected in the input
optstring=":svl:"

while getopts ${optstring} arg; do
  case ${arg} in
    v)
      VERBOSE='true'
      print_out "Verbose mode is ON"
      ;;
    l)
      LENGTH="${OPTARG}"
      ;;
    s)
      USE_SPECIAL_CHAR='true'
      ;;

    :) echo "[-${OPTARG}] requires a value"
       echo
       usage
    ;;

    ?)
      echo "Invalid option: -${OPTARG}."
      echo
      usage
      ;;
  esac
done
shift $((OPTIND -1 ))

print_out 'Generating a password'
PASSWORD=$(date +%s%N{RANDOM${RANDOM}} | sha256sum | head -c${LENGTH})

# Append a special character if requested to do so.
if [[ ${USE_SPECIAL_CHAR} == true ]];then
   print_out "Selecting a random special character"
   SPECIAL_CHAR=$(echo '!@#$%^&*()_+=' | fold -w1 | shuf | head -c1)
   PASSWORD="${PASSWORD}${SPECIAL_CHAR}"
fi

print_out 'Done'
print_out 'Here is your password'

# Display the password
echo "${PASSWORD}"
exit 0
