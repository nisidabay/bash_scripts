#!/usr/bin/bash
# Author: Carlos Lacaci Moya
# Show ASCII files in the path

for f in *;do
    if [[ $(file "$f") =~ "ASCII" ]];then
        echo "$f"
    fi
done
