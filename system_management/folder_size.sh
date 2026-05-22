#!/usr/bin/env bash
#
# Check if folder size exceeds a limit.
#
# Dependencies: du, awk

function folder_size() {
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
        rounded_total=${folder_without_unit//,*/}

        # Testing purposes. Can be safely removed
        echo "Size of the folder $folder_size"

        if (("$rounded_total" > "$SIZE")); then
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
