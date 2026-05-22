#!/usr/bin/env bash
#
# Change background image on i3wm using nitrogen.
#
# Dependencies: nitrogen

set -euo pipefail
################################################################################
export DISPLAY=":0"

# Defining the directory with wallpapers
BG_DIR=$HOME/Pictures

BG_NUM=$(ls -l "${BG_DIR}" | wc -l)
if [ $BG_NUM -ne 0 ]; then
	[ -f "${BG_DIR}"/current_bg_image.png ] && rm "${BG_DIR}"/current_bg_image.png

	# Feeding random generator with the date in seconds (UNIX time)
	RANDOM=$$$(date +%s)

	# Generating array of all wallpapers in the directory
	BG_LIST=("${BG_DIR}"/*)

	# Randomly select some number from the total number of wallpapers
	SELECTED_BG=$(($RANDOM % ${BG_NUM}))

	# Creating new symbolic link to the selected wallpaper with the name "current_bg_image.png"
	ln -s "${BG_LIST[$SELECTED_BG]}" "${BG_DIR}"/current_bg_image.png

	# Refreshing wallpaper image
	nitrogen --restore >/dev/null 2>&1 &
fi
