#!/usr/bin/bash
##################################################
# Name: check_args.sh
#
# Purpose: To verify inline args start with -
#
# Author: clm
#
# Date: sáb 12 jun 2021 17:17:37 CEST
#
# Version: 1.0
#
# Code from:
#
# Modified by:
## On Date Date:
#
# Actions taken:
#
# [+]
# [-]
################################################## 
for arg in $@
do
tmp=$arg
## DEGUB
# echo "Length of [$tmp] is: ${#tmp}"
# echo "First char of [$tmp] is: ${tmp:0:1}"
[ ${tmp:0:1} = "-" ] || echo "==> bad argument [$tmp]" 
shift
[ ${tmp:0:2}=[[0-9]] ] && echo "ok"
done
echo "Number of arguments passed: $#"
echo "Number of arguments passed: $*"
