#/bin/bash
echo "Enter the file name: "
read filename
[ -f $filename ] || echo "($filename) does not exist"

while IFS= read -r line
do
	echo "$line"
done<$filename
