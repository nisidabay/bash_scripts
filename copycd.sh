#!/bin/sh
#Script para copiar cdroms

# if [ $USER != "root" ];then
	# echo "Only ROOT can run this script...Bye."
	# exit 1
# fi

MPOINT="/tmp/copias"
if [ ! -d $MPOINT ];then
	echo "Mount point $MPOINT doesn't exit. I'll do it for you ;)"
	mkdir -m755 --verbose "$MPOINT"
	sleep 2
fi
  
if [ "$#" != "2" ];then
	echo "Missing some arguments."
	echo " <Usage: cdcopy copy_name copy_origin> "
	exit 2
else
	echo "Press a key to begin..."
	read
    mkisofs -l -o "$1" "$2"
fi

#checking the result

if [ "$?" == "0" ];then
	echo Do you want to check the previous copy? 
	read ANSWER
	case $ANSWER in
			Y* | y*)
					mount "$1" -r -t iso9660 -o loop $MPOINT
					ls -la $MPOINT;;
		
			*) 		;;
	esac
else
	echo "Some thing has happened. Check the script.!"
	exit 3
fi

echo Almost Done!.Do you want to burn the copy?
read ANS
	case $ANS in
		Y* | y*)
				echo Insert a recordable cdrom
				read
        		cdrecord dev=0,3,0 -v "$1";;
		*)
    			echo "The file will be saved as name $1. You can burn it later. Ciao!"
				eject cdrom
				exit 4;;
	esac
umount /mnt/cdrom
rm -rf $1 
rm -rf $MPOINT
