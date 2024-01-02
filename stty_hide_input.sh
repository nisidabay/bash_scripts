#!/usr/bin/bash

##############################################################################
# Idea from: Classic Shell Scripting
# Arnold Robbins & Nelson H.F. Beebe
# Description:
#
# /dev/tty is a special device. When a program opens a file, Unix automatically
# redirects it to the real terminal associated with the program.  The stty (set
# tty) command controls various settings of hyour terminan (or window). The
# -echo options turnos off the automatic printing (echoing of every character
# you type; stty echo restores it)
#
# Date: vie 10 feb 2023 07:27:45 CET
##############################################################################

echo -n "Enter new password: "
stty -echo # turn off echoing of typed characters
read pass < /dev/tty
echo
echo -n "Enter again: "
read pass2 < /dev/tty

stty echo # turn on echoing of typed characters
echo
if [ $pass == $pass2 ]; then 
    echo You can pass
else
    echo You cannot pass
fi

