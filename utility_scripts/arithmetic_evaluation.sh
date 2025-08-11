#!/usr/bin/bash
################################################################################
# Author: Carlos Lacaci Moya
# Description: Usage of arithmetic evaluation
#              Print odd numbers
# Date: jue 09 sep 2021 10:50:54 CEST
# Dependencies:
################################################################################

num=1
while (( num <= 20 ));do
    if ((  num % 2  == 0 ));then
        num=$((num +1))
        continue
    fi
    if (( num >= 15 ));then
        break
    fi
    echo $num
    num=$((num + 1))

done

