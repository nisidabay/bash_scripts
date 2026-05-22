#!/usr/bin/env bash
#
# Display running/queued task count for dwmblocks.
#
# Dependencies: tsp, notify-send
# Environment: $TERMINAL, $EDITOR

num=$(tsp -l | awk -v numr=0 -v numq=0 '{if (/running/)numr++; if (/queued/)numq++} END{print numr+numq"("numq")"}')

# Handle mouse clicks
case $BLOCK_BUTTON in
1) setsid -f "$TERMINAL" -e tsp -l ;;
3) notify-send "Tasks module" "🤖: number of running/queued background tasks
- Left click opens tsp" ;; # Right click
2) $EDITOR "$0" ;;         # Middle click
esac

[ "$num" != "0(0)" ] &&
    echo "🤖$num"
