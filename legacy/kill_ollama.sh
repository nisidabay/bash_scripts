#!/usr/bin/env bash
#
# LEGACY — preserved as example, requires local AI backend
# Kill the AI backend process (graceful → forceful escalation)

# --- Configuration ---
# The name of the process to display in messages.
DISPLAY_NAME="{{AI_BACKEND}}"
# The pattern to search for. The brackets prevent pgrep/pkill from matching their own process.
SEARCH_PATTERN="{{AI_BACKEND}} serve"

# Exit immediately if a command fails, making the script safer.
set -e

# --- Main Logic ---

echo "🔎 Checking for running '$DISPLAY_NAME' processes..."

# Use pgrep with the '-f' flag to match against the full command line using the safe pattern.
if pgrep -f "$SEARCH_PATTERN" &>/dev/null; then
    echo "✅ Found '$DISPLAY_NAME' process(es). Details:"
    # Use pgrep with '-af' to list the PIDs and full command lines for debugging.
    pgrep -af "$SEARCH_PATTERN"

    echo "🛑 Attempting graceful shutdown (SIGTERM)..."
    # Use pkill with '-f' to match the full command line with the safe pattern.
    # The '|| true' prevents the script from exiting if pkill fails.
    sudo pkill -f "$SEARCH_PATTERN" || true
    # Wait a couple of seconds to give the process time to shut down gracefully.
    sleep 2

    # Check if the process is still running after the graceful attempt.
    if pgrep -f "$SEARCH_PATTERN" &>/dev/null; then
        echo "⚠️ Process still running. Escalating to forceful shutdown (SIGKILL)..."
        # Use the -9 flag for SIGKILL, which cannot be ignored.
        sudo pkill -9 -f "$SEARCH_PATTERN" || true
        sleep 1
    fi

    # Final verification to confirm shutdown.
    if pgrep -f "$SEARCH_PATTERN" &>/dev/null; then
        echo "❌ FATAL: Failed to shut down '$DISPLAY_NAME' even with a forceful kill."
        exit 1
    else
        echo "✅ Success! '$DISPLAY_NAME' has been shut down."
    fi
else
    echo "❓ '$DISPLAY_NAME' is not running."
fi

exit 0
