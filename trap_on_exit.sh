#!/bin/bash
#
# Execute tasks when the EXIT signal is receivedk
#
# add_on_exit() function adds cleanup commands to an array on_exit_items.
# on_exit() function iterates over this array and executes each command upon script exit.

# The trap for EXIT is set the first time add_on_exit is called, ensuring all
# added commands are executed when the script exits.

# This approach allows adding new cleanup tasks at various points in the script
# without modifying the central cleanup logic, making the script more modular and
# easier to maintain.

declare -a on_exit_items

# Execute commands on exit
function on_exit() {
    for i in "${on_exit_items[@]}"
    do
        echo "on_exit: $i"
        eval "$i"
    done
}

# Add commands to execute on exit
function add_on_exit() {
    local n=${#on_exit_items[*]} # length of the array
    on_exit_items["$n"]="$*" # add item in the last position
    if [[ $n -eq 0 ]]; then
        echo "Setting trap"
        trap on_exit EXIT # setting trap the first time function is called
    fi
}

# Example usage
touch $$-1.tmp
add_on_exit rm -f $$-1.tmp

touch $$-2.tmp
add_on_exit rm -f $$-2.tmp

ls -la '*.tmp'

