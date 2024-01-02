#!/usr/bin/bash
# Author: https://gumirov.xyz/
# Description: Change background image on i3wm 
# Modified on: mar 22 feb 2022 11:37:36 CET
# Dependencies: nitrogen

# Debugging setup for bash
set -euo pipefail
################################################################################ 
# ENV VARIABLES
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
    SELECTED_BG=$(( $RANDOM % ${BG_NUM} ))

    # Creating new symbolic link to the selected wallpaper with the name "current_bg_image.png"
    ln -s "${BG_LIST[$SELECTED_BG]}" "${BG_DIR}"/current_bg_image.png

    # Refreshing wallpaper image
    nitrogen --restore > /dev/null 2>&1 &
fi

