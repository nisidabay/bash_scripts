#!/usr/bin/env bash
#
# Open vim mappings file in terminal editor.
#
# Dependencies: terminal, editor
# Environment: $WAYLAND_DISPLAY, $HOME

MAPPINGS_DIR="$HOME/bin/vim_mappings"
MAPPINGS_FILE="$MAPPINGS_DIR/vim_mappings.md"

TERMINAL="${TERMINAL:-st}"
EDITOR="${EDITOR:-vim}"

# Check if the mappings directory exists
if [ ! -d "$MAPPINGS_DIR" ]; then
    echo "Error: Mappings directory does not exist: $MAPPINGS_DIR"
    exit 1
fi

# Check if the mappings file exists
if [ ! -f "$MAPPINGS_FILE" ]; then
    echo "Error: Mappings file does not exist: $MAPPINGS_FILE"
    exit 1
fi

# Open the mappings file in the editor
"$TERMINAL" -e "$EDITOR" "$MAPPINGS_FILE"
