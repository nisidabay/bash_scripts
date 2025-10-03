#!/usr/bin/env bash

# lib_validation.sh - Reusable validation functions

# Generic validation function template
validate_with_pattern() {
    local input="$1"
    local pattern="$2"
    local error_msg="${3:-Invalid input}"

    [[ -z "$input" ]] && {
        echo "No input provided" >&2
        return 2
    }
    [[ -z "$pattern" ]] && {
        echo "No pattern provided" >&2
        return 2
    }

    if [[ "$input" =~ $pattern ]]; then
        return 0
    else
        echo "$error_msg: '$input'" >&2
        return 1
    fi
}

# Specific validation functions built on generic one
validate_email() {
    local email="$1"
    local email_pattern='^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
    validate_with_pattern "$email" "$email_pattern" "Invalid email address"
}

validate_phone() {
    local phone="$1"
    local phone_pattern='^\+?[0-9]{10,15}$'
    validate_with_pattern "$phone" "$phone_pattern" "Invalid phone number"
}

validate_positive_int() {
    local num="$1"
    local int_pattern='^[1-9][0-9]*$'
    validate_with_pattern "$num" "$int_pattern" "Must be a positive integer"
}

# ⚠️Usage example (would be in a separate script)
# The following example shows how to capture and use the specific exit code from a validation function.
validate_email "user@example.com"
result=$?

# A case statement can then be used to handle the different outcomes.
case $result in
0)
    echo "Valid email"
    ;;
1)
    # The function itself prints a detailed error to STDERR.
    # This block could contain additional logic for this error case.
    echo "Handling invalid email format."
    ;;
2)
    echo "Script error: A required argument was missing from the function call." >&2
    ;;
*)
    echo "An unknown error occurred." >&2
    ;;
esac
