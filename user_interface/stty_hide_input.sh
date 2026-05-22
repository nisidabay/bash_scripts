#!/usr/bin/env bash
#
# Hide input with stty for password entry.
#
# Dependencies: stty

echo -n "Enter new password: "
stty -echo # turn off echoing of typed characters
read pass </dev/tty
echo
echo -n "Enter again: "
read pass2 </dev/tty

stty echo # turn on echoing of typed characters
echo
if [ $pass == $pass2 ]; then
    echo You can pass
else
    echo You cannot pass
fi
