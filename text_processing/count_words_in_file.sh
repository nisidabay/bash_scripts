#!/usr/bin/bash
#
# Count the words in a file
# Assumes that the file exists. No more checkouts.
#
# Arguments:
#   $1 - The path of the file
#
# Returns:
#   Success a string indicating the number of words
#   Error a "File not found!" string
# 
# Author: nisidabay
function count_words_in_file(){
    FILE=$1

    if [ -e "$FILE" ]; then
        word=$(wc -w < "$FILE")

        echo "Number of words in the file: $word"
    else
        echo "File not found!"
    fi
}
# ---test
count_words_in_file "/path/to/file"
