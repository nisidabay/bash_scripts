#!/usr/bin/env bash
#
# Count the words in a file.
#
# Dependencies: wc

function count_words_in_file() {
    FILE=$1

    if [ -e "$FILE" ]; then
        word=$(wc -w <"$FILE")
        echo "Number of words in the file: $word"
    else
        echo "File not found!"
    fi
}

count_words_in_file "/path/to/file"
