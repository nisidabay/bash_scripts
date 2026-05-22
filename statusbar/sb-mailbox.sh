#!/usr/bin/env bash
#
# Display unread mail count for dwmblocks.
#
# Dependencies: offlineimap, notmuch, notify-send
# Environment: $TERMINAL, $EDITOR

declare -r MESSAGES_COUNT=~/.notmuch_count_messages

check_mail() {
    # Sync folders with offlineimap
    notify-send "📧 Checking mail ..."

    offlineimap -o -u quiet &

    # Wait for offlineimap to finish
    wait $!

    # Update notmuch database
    notmuch new >/dev/null
    wait $!

}

case $BLOCK_BUTTON in
1) setsid -f "$TERMINAL" -e neomutt ;;
2) check_mail ;;
3) notify-send "📬 Mail module" "\ - Shows unread mail
- Shows 🔃 if syncing mail
- Left click opens neomutt
- Middle click syncs mail" ;;
esac

new_total=$(notmuch count new)
old_total=$(cat $MESSAGES_COUNT)
# Ensure that always update the count of new messages
# old_total=$(( old_total - 1 ))
new_messages=$((new_total - old_total))
echo "$new_messages" >$MESSAGES_COUNT
if [[ $new_messages -ge 0 ]]; then
    echo -n "📬+$new_messages"
else
    echo -n "📬$new_total"
fi
