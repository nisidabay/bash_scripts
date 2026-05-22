#!/usr/bin/env bash
#
# Display system fonts via dmenu.
#
# Dependencies: dmenu, fc-list
# Environment: $HOME
# shellcheck disable=SC1091
# Source appearance config
[[ -f "${HOME}/bin/dmenu_wal.sh" ]] && source "${HOME}/bin/dmenu_wal.sh"

menu() {
    local prompt="$1"
    dmenu -i -c -l 15 "${DMENU_APPEARANCE[@]}" -p "$prompt"
}

# Create an associative array to hold font names and their paths
declare -A font_paths

# Fill the associative array with font names as keys and paths as values
# using process substitution
while IFS=: read -r path name; do
    font_paths["$name"]="$path"
done < <(fc-list | awk -F: '{print $1 ":" $2}' | sort -t: -k2,2 | uniq -f1)

# Print font names to the user for selection
choice=$(printf "%s\n" "${!font_paths[@]}" | menu "Select font:")

# Exit if no choice is made
[ -z "$choice" ] && exit

# Display the chosen font using its path using display command
display "${font_paths[$choice]}"
