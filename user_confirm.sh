#!/usr/bin/bash
##############################################################################
# Idea from: Groctel
# Author:  Groctel
# Description: Ask user for confimation before taking an action
# Date:
# Dependencies:
##############################################################################
function Confirm ()
{
	answer=-1

	case "$1" in
	[Yy][Ee][Ss])
		printf "\033[1;32m:: \033[0m%s? \033[1;32m[Y/n]:\033[0m " "$2"
	;;
	[Nn][Oo])
		printf "\033[1;31m:: \033[0m%s? \033[1;31m[y/N]:\033[0m " "$2"
	;;
	 *)
		 printf "\033[1;33m:: \033[0m%s? \033[1;33m[y/n]:\033[0m " "$1"
	 ;;
	esac

	while [ $answer -eq -1 ]
	do
		read -r yn

		case $yn in
		[Yy]*)
			answer=0
		;;
		[Nn]*)
			answer=1
		;;
		*)
			case "$1" in
			[Yy][Ee][Ss])
				answer=0
			;;
			[Nn][Oo])
				answer=1
			;;
			esac
		;;
		esac
	done

	return $answer
}
#--- test
if Confirm "Yes" "Want to quit"; then
    echo Quitting
fi
