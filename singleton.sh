#!/bin/bash

# Bash script illustrating singleton pattern

# Declare an associative array to hold singleton instances
declare -A instances

# Function to get or create a singleton instance
get_singleton_instance() {
    local singleton="$1"

    # Check if the instance does not exist and create it if necessary
    if [[ -z ${instances["$singleton"]} ]]; then
        # Initialize the singleton with the current script's process ID ($$)
        instances["$singleton"]=$$
    fi
    # Return the instance's value (process ID)
    echo "${instances["$singleton"]}"
}

# Function to update a singleton instance
update_singleton_instance() {
    local singleton="$1"
    # Update the singleton's value to the current script's process ID ($$)
    instances["$singleton"]=$$
}

# Using the singleton design pattern
value="value1"
# Retrieve the first instance
instance1=$(get_singleton_instance "$value")
echo "Initial Instance 1: $instance1"

# Simulate an update to the singleton instance
update_singleton_instance "$value"
# Retrieve the instance again, after update
instance2=$(get_singleton_instance "$value")
echo "Updated Instance 1: $instance1"
echo "Instance 2: $instance2"

# Function to print all singleton instances
print_shared_data() {
    echo "All singleton instances:"
    for key in "${!instances[@]}"; do
        echo "$key: ${instances[$key]}"
    done
}

# Display all the instances
print_shared_data
