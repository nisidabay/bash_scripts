#!/usr/bin/env bash
#
# Ignoring Interruptions Example
# This script demonstrates how to temporarily ignore SIGINT
# during critical operations, then restore normal behavior

# Configuration
ERROR_LOG="error_log.txt"
OUTPUT_TO_STDOUT="true" # Set to "true" to also output to stdout

# Open log file once for appending
exec 3>>"$ERROR_LOG"

# Function: logger
# Description: Appends input lines to the configured ERROR_LOG file.
# Arguments: None (reads from stdin)
# Usage: echo "Log message" | logger
logger() {
    while IFS= read -r line; do
        echo "$line" >&3
        if [[ "$OUTPUT_TO_STDOUT" == "true" ]]; then
            echo "$line"
        fi
    done
}

# Function: handle_interrupt
# Description: Handles SIGINT (Ctrl+C) signals. Logs the interruption event
#              with the exit code and line number, then exits.
# Arguments:
#   $1 - The line number where the interrupt occurred ($LINENO).
# Side Effects: Logs to ERROR_LOG and exits the script with code 1.
handle_interrupt() {
    local exit_code=$?
    local line_number=$1
    echo "INTERRUPT: with code $exit_code at line $line_number" | logger
    exit 1
}

# Function: setup_default_sigint_handler
# Description: Sets up the default SIGINT handler to call 'handle_interrupt'
#              when a SIGINT signal is received.
# Arguments: None
setup_default_sigint_handler() {
    trap 'handle_interrupt $LINENO' SIGINT
}

# Function: perform_work
# Description: Simulates performing some work, logging messages and steps.
# Arguments:
#   $1 - message: A string message to log at the start of the work.
#   $2 - steps: The number of steps to simulate.
#   $3 - log_to_file: Optional. If "true" (default), messages are logged to ERROR_LOG.
#                     If "false", no logging occurs within this function.
perform_work() {
    local message="$1"
    local steps="$2"

    echo "$message" | logger
    for i in $(seq 1 "$steps"); do
        echo "Step $i/$steps..." | logger
        sleep 1
    done
}

# Function: critical_operation
# Description: Performs a critical operation that temporarily ignores SIGINT signals.
#              Logs the start and completion of the critical operation.
# Arguments: None
# Side Effects: Temporarily modifies SIGINT trap, logs to ERROR_LOG.
critical_operation() {
    echo "Starting critical operation." | logger

    # Temporarily ignore SIGINT
    trap '' SIGINT

    # Simulate critical work (output not logged by perform_work, but by critical_operation's start/end)
    perform_work "Critical work" 5

    # Restore the default SIGINT behavior
    setup_default_sigint_handler

    echo "Critical operation completed successfully." | logger
}

# Main execution
setup_default_sigint_handler

perform_work "Performing normal work..." 3

critical_operation

perform_work "Performing more normal work..." 3
exec 3>&-
