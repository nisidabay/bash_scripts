#!/bin/bash
#
# video-convert .01
# crmanski / http://szone.berlinwall.org
# Requirements: zenity (Comes with gnome 2.4), ffmpeg (apt-get ffmpeg)
# This script will take multiple video files of the same type (right now: MPG, AVI, MOV) 
# and covert them into either NTSC - dvd, svcd or vcd compliant MPEG files by using
# ffmpeg (http://ffmpeg.sourceforge.net)
#
# Installation:
# Place the script in the Nautilus scripts folder (/home/YourUserName/.gnome2/nautilus-scripts)
# Make sure the file is executable
# Select some video files. This works well on the video files my digital camera makes
# Choose Scripts->video-convert
#
# Background and Credits:
# I came across the very nicely done audio-convert script in the ubuntu forums
# http://ubuntuforums.org/showthread.php?t=48007
# and thought how nice it would be to not have to open each file I want to convert in avidemux
# manually or by using a script for each file(s) using ffmpeg. So after looking at 
# http://g-scripts.sourceforge.net/ and some of the scripts there:
# http://g-scripts.sourceforge.net/nautilus-scripts/Multimedia/Image/NIS
# http://g-scripts.sourceforge.net/nautilus-scripts/Multimedia/Image/convert_to_jpeg
# I ended up working this out with various bits and pieces of the above mentioned scripts.
# It is not pretty but it works for me.  Have fun!
#
# License:
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  
# USA

#Has a file been selected?
if [ $# -eq 0 ]; then
	zenity --error --title="error" --text="You must select at least 1 file to process"
	exit 1
fi

zenity --question \
        --text="This Script converts selected AVI, MOVE or MPG files to NTSC-DVD, SVCD or VCD compliant MPG files with ffmpeg. Proceed?"

#if $? != 0, user clicked on cancel button, so exit
if [ "$?" != 0 ] ; then
	exit
fi

#Input - What Type?
# Laziness. I am not detecting video mime types.
title="Choose which type the input video files are..."
video_in_type=`zenity --title "$title"  --list --separator=" " --column="Choose Input Video Type" "AVI" "MOV" "MPG" | sed 's/ max//g' `
#user must select a target size
if [ ! "$video_in_type" ]; then
	zenity --error --title="Error" --text="You must select a Input Type"
	exit
fi

#Output - What kind?
title="What kind of Video are you making?"
video_out_type=`zenity --title "$title"  --list --separator=" " --column="Output to..." "DVD" "SVCD" "VCD" | sed 's/ max//g' `
#user must select a target size
if [ ! "$video_out_type" ]; then
	zenity --error --title="Error" --text="You must select a Input Type"
	exit
fi

# If we are making DVD there are a few options...
if [ "$video_out_type" = "DVD" ]; then
	
	#What Size?
	title="Choose which resolution the video files should be..."
	dvd_res=`zenity --width="480" --height="480" --title "$title"  --list --separator=" " --column="Choose Video Resolution" "ntsc-dvd -s 720x480" "ntsc-dvd -s 720x400 -padtop 40 -padbottom 40" "ntsc-dvd -s 704x480" "ntsc-dvd -s 704x396 -padtop 42 -padbottom 42" "ntsc-dvd -s 352x480" "ntsc-dvd -s 352x240" "ntsc-dvd -s 352x196 -padtop 22 -padbottom 22"| sed 's/ max//g' `
	#user must select a target size
	if [ ! "$dvd_res" ]; then
		zenity --error --title="Error" --text="You must select a target resolution."
		exit
	fi
	title="Choose the audio bitrate your video files should have..."
	audio_br=`zenity --title "$title"  --list --separator=" " --column="Choose Audio Bitrate" "448" "356" "224" "160" "128" | sed 's/ max//g' `
	#user must select an audio bitrate
	if [ ! "$audio_br" ]; then
		zenity --error --title="Error" --text="You must select an audio bitrate."
		exit
	fi
	title="Choose the audio stream type your video files should have..."
	audio_str=`zenity --title "$title"  --list --separator=" " --column="Choose Audio Stream Type" "ac3" "mp2" | sed 's/ max//g' `
	#user must select an audio bitrate
	if [ ! "$audio_str" ]; then
		zenity --error --title="Error" --text="You must select an audio stream type."
		exit
	fi
fi

#Video Encoding Functions...
dvd_encode ()
{
	/usr/bin/ffmpeg -i "$movie" -target $dvd_res -sameq -hq -r 29.97 -aspect 4:3 -ab $audio_br -ar 48000 -ac 2 -acodec $audio_str -y "$mpg_file"
}
svcd_encode ()
{
	/usr/bin/ffmpeg -i "$movie" -target ntsc-svcd -sameq -hq -aspect 4:3 -y "$mpg_file"
}
vcd_encode ()
{
	/usr/bin/ffmpeg -i "$movie" -target ntsc-vcd -sameq -hq -aspect 4:3 -y "$mpg_file"
}

#Input Selection was AVI Video
if [ "$video_in_type" = "AVI" ]; then
	mime=`file -bi $*`
	nb_video=`echo "$mime" | grep video/x-msvideo | wc -l`

	let "nbfiles = $nb_video"

	while [ $# -gt 0 ]; do
		movie=$1
		mpg_file=`echo "$movie" | sed 's/\.\w*$/.mpg/'`
		mime=`file -bi "$movie"`
		isvideo=`echo "$mime" | grep video/x-msvideo | wc -l`
		if [ $isvideo -eq 0 ]; then
			zenity --error --title="error" --text="$movie is not an AVI video file"
		else
			echo "# Processing AVI Video $movie ..."
			if [ "$video_out_type" = "DVD" ]; then
				dvd_encode
			fi
			if [ "$video_out_type" = "SVCD" ]; then
				svcd_encode
			fi
			if [ "$video_out_type" = "VCD" ]; then
				vcd_encode
			fi
		fi	
		
		shift
	done|
	        zenity --progress --auto-close --title="Converting AVI Video Files"  --text="Converting AVI Video Files..."  --percentage=0
fi

#Input Selection was Quicktime Video
if [ "$video_in_type" = "MOV" ]; then
	mime=`file -bi $*`
	nb_video=`echo "$mime" | grep application/octet-stream | wc -l`

	let "nbfiles = $nb_video"

	while [ $# -gt 0 ]; do
		movie=$1
		mpg_file=`echo "$movie" | sed 's/\.\w*$/.mpg/'`
		mime=`file -bi "$movie"`
		isvideo=`echo "$mime" | grep application/octet-stream | wc -l`
		if [ $isvideo -eq 0 ]; then
			zenity --error --title="error" --text="$movie is not a Quicktime video file"
		else
			echo "# Processing Quicktime Video $movie ..."
			if [ "$video_out_type" = "DVD" ]; then
				dvd_encode
			fi
			if [ "$video_out_type" = "SVCD" ]; then
				svcd_encode
			fi
			if [ "$video_out_type" = "VCD" ]; then
				vcd_encode
			fi
		fi	
		
		shift
	done|
	        zenity --progress --auto-close --title="Converting Quicktime Video Files"  --text="Converting Quicktime Video Files..."  --percentage=0
fi

#Input Selection was MPG Video
if [ "$video_in_type" = "MPG" ]; then
	mime=`file -bi $*`
	nb_video=`echo "$mime" | grep video/mpeg | wc -l`

	let "nbfiles = $nb_video"

	while [ $# -gt 0 ]; do
		movie=$1
		mpg_file=`echo "$movie" | sed 's/\.\w*$/_NTSC-DVD.mpg/'`
		mime=`file -bi "$movie"`
		isvideo=`echo "$mime" | grep video/mpeg | wc -l`
		if [ $isvideo -eq 0 ]; then
			zenity --error --title="error" --text="$movie is not a MPG video file"
		else
			echo "# Processing MPG Video $movie ..."
			if [ "$video_out_type" = "DVD" ]; then
				dvd_encode
			fi
			if [ "$video_out_type" = "SVCD" ]; then
				svcd_encode
			fi
			if [ "$video_out_type" = "VCD" ]; then
				vcd_encode
			fi
		fi	
		
		shift
	done|
	        zenity --progress --auto-close --title="Converting MPG Video Files"  --text="Converting MPG Video Files..."  --percentage=0
fi
