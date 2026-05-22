#!/usr/bin/env bash
#
# Show and insert shell loop templates.
#
# Dependencies: dmenu, xdotool, notify-send
# Environment: $HOME
DMENUFONT="Fisa Code:style=Italic:size=12"
declare -a loops

loops=(
    "while1: while ((\$z<=10));do z=\$((z+1));done"
    "while2: while [ \"\$z\" -lt 10 ];do z=\$((z+1));done"
    "while3: while true;do conditions;done"
    "for1: for ((i=1; i<=10; i++));do conditions;done"
    "for2: for i in {1..10};do conditions;done"
    "for3: for i in \$(seq 1 10);do conditions;done"
)

# Use dmenu to display the list of concepts and get user input
choice=$(printf '%s\n' "${loops[@]}" | dmenu -i -p "Choose a loop expression to insert:" -l 20 -fn "$DMENUFONT")

# Exit if user cancelled
[[ -z "$choice" ]] && exit 0

# Extract the regular expression from the user's choice
expression=$(echo "$choice" | awk -F ":" '{print $2}')

# Insert the regular expression into the current application
xdotool type "$expression"
