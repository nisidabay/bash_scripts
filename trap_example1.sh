#!/usr/bin/bash
# Author: Carlos Lacaci Moya
# Description: Capture exit 0 status
# Date: 
# Dependencies:
trap "echo Exit command is detected" 0
echo "Hello World"
exit 0
