#!/usr/bin/env bash
#
# Display desktop notifications.
#
# Dependencies: notify-send, osascript

# Check the operating system
if [[ "$untracked_changes" -gt 0 || "$staged_changes" -gt 0 ]]; then
    if [[ $(uname) == "Linux" ]]; then
        # On Linux, use notify-send
        notify-send -i "$SCRIPT_PATH/git.png" "Untracked changes:" "$untracked_changes"
        notify-send -i "$SCRIPT_PATH/git.png" "Staged changes:" "$staged_changes"
        notify-send -i "$SCRIPT_PATH/git.png" "Check log file" "$LOG_FILE"
        sleep 2
        see_log
    elif [[ $(uname) == "Darwin" ]]; then
        # On macOS, use osascript to send AppleScript notification
        osascript -e "display notification \"Untracked changes: $untracked_changes\" with title \"Git Status\""
        sleep 2
        osascript -e "display notification \"Staged changes: $staged_changes\" with title \"Git Status\""
        sleep 2
        osascript -e "display notification \"Check log file: $LOG_FILE\" with title \"Git Status\""
        sleep 2
        see_log
    else
        echo "Unsupported operating system"
    fi
fi
