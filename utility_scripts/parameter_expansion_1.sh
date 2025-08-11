#!/usr/bin/bash
##################################################
# Name:     parameter_expansion_1.sh
#
# Purpose:  Check if variable is unset
#           Conditional
# Author:
#
# Date: vie 18 jun 2021 19:40:50 CEST
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

# Identical behaviour. param is UNSET
# return default
echo ${param-default}
echo ${param=default}

# Identical behaviour. param is ""
# return ""
param=""
echo ${param-""}
echo ${param=""}

# Identical behaviour. param is "gnu"
# return gnu
param="gnu"
echo ${param-gnu}
echo ${param=gnu}


# param is UNSET
# return -
${param+alternate}
