#!/usr/bin/bash
#
# Log header separator. Change it to your needs
LOG_FILE=$HOME/log.txt
header_separator(){
# Get the current date
_date=$(date)
header="Logging started at $_date"

# Check if an argument is provided
if [[ $# -gt 0 && $1  == "end" ]]; then
    # If provided argument: use "Logging ended"
    header="Logging ended at $_date" 
fi

# Get the length of the header
separator_length=${#header}

# Create a separator of the same length as the header
separator=$(printf '%*s' "$separator_length" | tr ' ' '-')

# Print the header and separator to the log file
printf "%s\n%s\n" "$header" "$separator" >> "$LOG_FILE" 
}

# Usage
: '
    header_separator
    header_separator "end"
'
