#!/usr/bin/env bash
#
# Demonstrate ternary operator usage.
#
# Dependencies: bash

age=25

result=$((age >= 18 ? 1 : 0))
if [ $result -eq 1 ]; then
    echo "You can vote"
else
    echo "You cannot vote"
fi
