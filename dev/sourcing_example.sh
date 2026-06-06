#!/usr/bin/env bash
#
# Demonstrate sourcing a script in Bash.
#
# Dependencies: none

#  With the "source" command we make the changes visible in the current Bash
#  shell

# Create a Bash script named script.sh
echo 'export MY_VARIABLE="Hello from script"' >script.sh

# Source the script within the current Bash shell
source script.sh

# Access the variable set in the sourced script
echo "MY_VARIABLE is set to: $MY_VARIABLE"
