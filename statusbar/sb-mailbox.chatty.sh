#!/usr/bin/env bash
#
# Display unread mail count with sync for dwmblocks.
#
# Dependencies: offlineimap, notify-send
# Environment: $TERMINAL, $EDITOR

# Define configuration variables
readonly MESSAGES_COUNT_FILE=~/.notmuch_count_messages
readonly MAIL_COMMAND="neomutt"

# Define functions
check_mail() {
    # Sync folders with offlineimap
    notify-send "📧 Checking mail ..."

    offlineimap -o -u quiet &

    # Wait for offlineimap to finish
    wait $!
}

# Handle mouse clicks
case $BLOCK_BUTTON in
1) setsid -f "$TERMINAL" -e "$MAIL_COMMAND" ;;
2) check_mail ;;
3) notify-send "📬 Mail module" "\
- Shows unread mail
- Shows 🔃 if syncing mail
- Left click opens $MAIL_COMMAND
- Middle click syncs mail" ;;
esac

# Calculate new message count and display output
if total_count=$(notmuch count new); then
    old_count=$(cat "$MESSAGES_COUNT_FILE" 2>/dev/null || echo 0)

    if ((new_count = total_count - old_count)); then
        echo "📬+$new_count"
    else
        echo "📬$total_count"
    fi

    echo "$total_count" >"$MESSAGES_COUNT_FILE"
else
    echo "🚫 Error getting message count"
fi
