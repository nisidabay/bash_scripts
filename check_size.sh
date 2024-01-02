# Check the size of a file

read -p "Enter the name of the file with extension: " FILE

get_file_size=$( ls -la $FILE | cut -d" " -f5 ) 


if [ $get_file_size -gt 1024 ] && [ $get_file_size -lt 1024000 ]
then 
	echo [+] File size is:  $(( $get_file_size / 1024 )) Kilobytes

elif [ $get_file_size -gt 1024000 ] 
then
	echo [+] File size is:  $(( $get_file_size / 1024000 )) Megabytes
else

	echo [+] File size is:  $get_file_size Bytes 
fi
