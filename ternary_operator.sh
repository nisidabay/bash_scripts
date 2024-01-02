#!/usr/bin/bash
################################################################################
# Author: Carlos Lacaci Moya
# Description: Usage of ternary operator
# Date: 
# Dependencies:
################################################################################
can_vote=0
age=18

((age >= 18?(can_vote=1):(can_vote=0)))
echo "Can Vote: $can_vote"

result=$(( 1 == 2 ? "true" : "false" ))
echo $result  

