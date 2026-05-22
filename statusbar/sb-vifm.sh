#!/usr/bin/env bash
#
# Launch file managers from dwmblocks.
#
# Dependencies: terminal, vifm or lf or yazi
# Environment: $TERMINAL
VIFM=vifm
LF=lf
YAZI=yazi

case $BLOCK_BUTTON in
# Launch in a new, independent session
1) setsid "$TERMINAL" -e "$VIFM" ;;
2) setsid "$TERMINAL" -e "$LF" ;;
3) setsid "$TERMINAL" -e "$YAZI" ;;
esac

echo "📁"
