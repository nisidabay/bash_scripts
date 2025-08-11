#!/usr/bin/bash
#
# Calculates the size of a folder against a specified limit
# Assumes that the folder exists. No more checkouts.
#
# Arguments:
#   $1 - The folder to get the size from
#   $2 - The size to check against as a top limit
#   $3 - The unit M (Megabyte) - K (Kilobytes) as reference for calculation
#
# Returns:
#   0 - If the size of the the folder is greater that the limit
#   1 - If it's not
#   127 - If the units to compare are different 
# 
# Author: nisidabay
function folder_size(){
    DIR=$1
    SIZE=$2
    UNIT=$3

    if [ -d "$DIR" ]; then
        folder_size=$(du -hs "$DIR" | awk 'END{print $1}')

        # Check the real UNIT and the one provided as argument
        real_unit=${folder_size:(-1):1}
        argument_unit=$UNIT
        if [[ $real_unit != "$argument_unit" ]]; then 
            echo "Trying to compare different units!"
            echo "The folder size is measure in: $real_unit"
            echo "You are comparing against : $argument_unit"
            return 127
        fi

        # Remove the UNIT. Get the number size
        folder_without_unit=${folder_size%"$UNIT"}
        rounded_total=${folder_without_unit//,*}
        
        # Testing purposes. Can be safely removed
        echo "Size of the folder $folder_size"

        if (( "$rounded_total" > "$SIZE" )); then
            # Testing purposes. Can be safely removed
            echo "Size of the folder is bigger than the limit $SIZE$UNIT"
 
            return 0
        else
            # Testing purposes. Can be safely removed
            echo "Size of the folder is less than the limit $SIZE$UNIT"
 
            return 1
        fi
    fi
}

#---- test
folder_size "$(pwd)" 1 K 
