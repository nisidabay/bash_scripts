#!/bin/bash
#
# Generate random errors log
#
# Array of error messages
declare -a messages=(
  "Unable to connect to server"
  "File not found"
  "Invalid input"
  "Out of memory"
  "Network error"
)
# Array of alert messages
declare -a alerts=(
    "error"
    "warning"
    "critical"
    "debug"
    "info"
    )
function random_log {
    
# Set the number of messages to generate
num_messages="$1"

# Initialize a counter variable
count=0

# Generate random error messages
while [ "$count" -lt "$num_messages" ]; do
    
  # Choose a random error message from the array
  error=${messages[$RANDOM % ${#messages[@]}]}
  
  # Choose a random alert messages from the array
  warnings=${alerts[$RANDOM % ${#alerts[@]}]} 
  
  # Generate a timestamp for the error
  timestamp=$(date '+%Y-%m-%d %H:%M:%S')
  
  # Print the error message with a timestamp
  echo "$timestamp $warnings: $error" >> error.log
  
  # Increment the counter
  ((count++))
done
} 

random_log "$1"

