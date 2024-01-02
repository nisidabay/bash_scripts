#!/usr/bin/bash
#
# File descriptor to monitorize a log file and send a message
#
# Arguments: "error.log" file
#
# Simulate a process in the background that reads a log file using a file 
# descriptor.
#
cleanup() {
# Define the cleanup function to be called when the script receives the SIGINT
# signal (e.g. when you press Ctrl-C)
  echo "Cleaning up..."
  echo exiting from "$0"
  # Close file descriptor
  exec 4<&-
  exit 1
}

# Set up the signal trap to catch the SIGINT signal and call the cleanup function
trap cleanup INT


mk_descriptor() {
  file="$1"
  exec 4< <(tail -f "$file")
  while read -r line <&4 ; do
    if echo "$line" | grep -iq "error"; then
      echo "Error detected in $file: $line"
      "$MAILCMD" -s "Error detected in $file" nisidabay@gmail.com <<< "$line"
    elif echo "$line"  | grep -iq "warning"; then
      echo "Warning detected in $file: $line"
      "$MAILCMD" -s "Warning detected in $file" nisidabay@gmail.com <<< "$line"
    fi
    sleep 0.5
  done
  
  # Close the file descriptor
  exec 4<&-
}

# Call the mk_descriptor function
mk_descriptor "$1"

echo "Script finished"
