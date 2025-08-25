#!/usr/bin/env bash
#
# This script demonstrates two methods for modifying a variable's value from
# within a function:

# 1. Using `nameref` (name reference), available in Bash 4.3 and newer.
# 2. Using indirect variable expansion.
#
# Both methods achieve a similar result: they allow a function to modify a
# variable defined in the calling scope, mimicking "pass-by-reference."

# shellcheck disable=SC2034
# The 'shellcheck' directive above tells the linter to ignore a warning
# about the variable 'name' not being read. We know it is being modified.

# ==============================================================================
# Method 1: Using a name reference (`nameref`)
# This is generally the preferred, more modern method.
# ==============================================================================
change_ref_values() {
    # 'declare -n ref' creates a nameref variable named `ref`.
    # This means `ref` will act as an alias or "pointer" to another variable.
    declare -n ref

    # We assign the name of the variable passed as the first argument ($1)
    # to the `ref` nameref. `ref` now points to the original variable.
    ref="$1"

    printf "Using nameref:\n"
    printf "  Original value: %s\n" "$ref"

    # When we assign a new value to `ref`, we are actually changing the value
    # of the original variable it points to (`name` in this case).
    ref="Pepe"

    printf "  Modified value: %s\n" "$ref"
}

# ==============================================================================
# Method 2: Using indirect variable expansion
# This method works in older versions of bash.
# ==============================================================================
change_indirect_values() {
    # The first argument ($1) is the name of the variable we want to change.
    local original_name="$1"

    # This variable now holds the *name* of the other variable.
    local indirect_value="$original_name"

    # We use a special syntax `"${!variable}"` to get the value of the variable
    # whose name is stored in `variable`. This is called indirect expansion.
    if [[ -n "${!indirect_value+x}" ]]; then
        printf "Using indirect expansion:\n"
        printf "  Original value: %s\n" "${!indirect_value}"

        # `printf -v` is used to assign a value to a variable.
        # It's a safer way to assign values to a variable whose name is dynamic,
        # preventing issues with spaces or special characters.
        printf -v "$indirect_value" "Juan"
    fi

    # We use indirect expansion again to show the updated value.
    printf "  Value changed: %s\n" "${!indirect_value}"
}

# Define a variable in the global scope.
name="Carlos"

# Call the first function, passing the name of the variable.
change_ref_values "name"

# Reset the variable back to its original value for the next demonstration.
name="Carlos"

# Call the second function, also passing the name of the variable.
change_indirect_values "name"
