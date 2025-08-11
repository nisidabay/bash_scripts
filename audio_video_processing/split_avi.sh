#!/usr/bin/bash

# Check if ffmpeg is installed
if ! command -v ffmpeg &> /dev/null; then
    echo "ffmpeg is not installed. Please install it first."
    exit 1
fi

# Check if an input file is provided as an argument
if [ $# -ne 1 ]; then
    echo "Usage: $0 input_file.avi"
    exit 1
fi

input_file="$1"
output_dir="splitted_avi"

# Create the output directory if it doesn't exist
mkdir -p "$output_dir"

# Use ffmpeg to split the AVI file into smaller AVI chunks
ffmpeg -i "$input_file" -c:v copy -c:a copy -map 0 -f segment -segment_time 00:30:00 -reset_timestamps 1 -segment_format avi "$output_dir/output_%03d.avi"

echo "AVI file has been split into smaller chunks in the '$output_dir' directory."

