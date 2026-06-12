#!/usr/bin/env bash
#
# Display transmission torrent status for dwmblocks.
#
# Dependencies: transmission-remote, notify-send
# Environment: $TERMINAL, $EDITOR
transmission-remote -l | grep -v "Sum:" | tail -n +2 |
    sed "
    s/^.*[[:space:]]Stopped[[:space:]].*/🛑/;
    s/^.*[[:space:]]Idle[[:space:]].*/🕰️/;
    s/^.*100%.*Done.*/✅/;
    s/^.*[[:space:]]Up[[:space:]].*/⬆️/;
    s/^.*[[:space:]]Down[[:space:]].*/⬇️/" |
    sort | uniq -c | awk '{print $2 $1}' | paste -sd ' ' -
# Handle click events
case $BLOCK_BUTTON in
# Middle click: Stop transmission service
2) echo "$SSHPASS" | sudo -S systemctl stop transmission.service ;;

# Right click: Show help notification
3) notify-send "🌱 Torrent module" "\- Middle click to stop transmission
- Right click to show this help
Module shows number of torrents:
🛑: paused
🕰: idle (seeds needed)
⬆️: uploading (unfinished)
⬇️: downloading
✅: done
🌱: done and seeding" ;;
esac
