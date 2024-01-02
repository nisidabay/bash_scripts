#!/bin/bash

# Convert MKV to AVI using ffmpeg
set -euox pipefail

# Check if ffmpeg is installed
if ! command -v ffmpeg &> /dev/null; then
    echo "ffmpeg could not be found, please install it."
    exit 1
fi

# Check for input arguments
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 input.mkv output.avi"
    exit 1
fi

# Assign the arguments to variables
input="$1"
output="$2"

# Execute the conversion
ffmpeg -i "$input" -c:v libxvid -c:a libmp3lame -q:v 3 -q:a 3 "$output"

# Check if the conversion was successful
if [ $? -eq 0 ]; then
    echo "Conversion complete: ${output}"
else
    echo "Conversion failed."
    exit 1
fi

