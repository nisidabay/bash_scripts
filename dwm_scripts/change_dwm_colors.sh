#!/usr/bin/bash
#
# Change the backup colors in dwm.
# By default dwm look for colors in .Xresources and if it cannot find the
# color required there it falls back to its configuration.
#
# It was a mere attemp to modify dwm apperances but its not worthy:
# 1) dwm will loop up always for .Xresources and if it's not found won't start.
# 2) you have to compile dwm and as before it will look up for .Xresources.
# 3) consider this script as a REGEX practice.
#
# Set the path to the colors-wal-dwm.h file
COLORS_FILE="$HOME/.cache/wal/colors-wal-dwm.h"
[[ -f $COLORS_FILE ]] || echo COLORS_FILE not exist 
# Set the path to the config.def.h file
CONFIG_FILE="$HOME/dwm-luke/config.h"
[[ -f $CONFIG_FILE ]] || echo COLORS_FILE not exist 

# Extract the color values from colors-wal-dwm.h
NORM_BG=$(grep "^static const char norm_bg" $COLORS_FILE | cut -d '"' -f 2)
echo "This would be the new normbgcolor $NORM_BG"
NORM_BORDER=$(grep "^static const char norm_border" $COLORS_FILE | cut -d '"' -f 2)
echo "This would be the new normbordercolor $NORM_BORDER"
NORM_FG=$(grep "^static const char norm_fg" $COLORS_FILE | cut -d '"' -f 2)
echo "This would be the new normfgcolor $NORM_FG"

SEL_FG=$(grep "^static const char sel_fg" $COLORS_FILE | cut -d '"' -f 2)
echo "This would be the new selfgcolor $SEL_FG"
SEL_BORDER=$(grep "^static const char sel_border" $COLORS_FILE | cut -d '"' -f 2)
echo "This would be the new selbordercolor $SEL_BORDER"
SEL_BG=$(grep "^static const char sel_bg" $COLORS_FILE | cut -d '"' -f 2)
echo "This would be the new selbgcolor $SEL_BG"

# Write the color values to config.def.h
sed -i "s/^\(static char normbgcolor\[\] = \).*/\1\"$NORM_BG\";/" $CONFIG_FILE
sed -i "s/^\(static char normbordercolor\[\] = \).*/\1\"$NORM_BORDER\";/" $CONFIG_FILE
sed -i "s/^\(static char normfgcolor\[\] = \).*/\1\"$NORM_FG\";/" $CONFIG_FILE
sed -i "s/^\(static char selfgcolor\[\] = \).*/\1\"$SEL_FG\";/" $CONFIG_FILE
sed -i "s/^\(static char selbordercolor\[\] = \).*/\1\"$SEL_BORDER\";/" $CONFIG_FILE
sed -i "s/^\(static char selbgcolor\[\] = \).*/\1\"$SEL_BG\";/" $CONFIG_FILE

# Modify the colors array declaration in config.def.h
sed -i "s/static char \*colors\[\]\[\] = {/static char \*colors[][3] = {/" $CONFIG_FILE
