#!/usr/bin/bash
# Idea from:ChatGPT & Luke Smith
# Encrypt a usb drive
# Date: lun 06 feb 2023 05:23:08 CET

declare -a usb_devices
declare selected_usb
declare -r MOUNT_DIR="/mnt/encrypted"
declare -g verbose 

# Colors
cyan=$(tput setaf 12)
purple=$(tput setaf 13)
reset=$(tput sgr0)

alert(){
 # Show alert message 
 tput civis
 printf "${purple}  %s${reset}\n" "$*"
 tput cnorm
 }

 message(){
 # Show message
 tput civis
 printf "${cyan} %s${reset}\n" "$*"
 tput cnorm
 }

function chk_dependencies(){
    # This function checks if the programs passed as strings are installed
    tput civis
    local -r dependencies_array=("$@")
    local missing=()

    for program in "${dependencies_array[@]}"; do
        if [[ "$(command -v "$program")" ]]; then
            if [[ -n "$verbose" ]]; then
                printf "Dependency satisfied: " && message "$program"
            fi
        else
            printf "Dependency needed: " && alert "$program"
            missing+=("$program")
        fi
    done

    if [[ "${#missing[@]}" -gt 0 ]]; then
        printf "Install the missing dependencies before continuing: " && alert ${missing[*]}
        tput cnorm
        exit 1
    fi

    tput cnorm
}

function show_usb_drives(){
    # Show all USBs plugged into the system
    all_details=$(lsblk --output NAME,SERIAL,MODEL,TRAN,TYPE,SIZE,FSTYPE,MOUNTPOINT | grep usb) 
    printf "%-10s %-20s %-17s %-5s %-6s %-6s %-10s %-10s\n" "NAME" "SERIAL" "MODEL" "TRAN" "TYPE" "SIZE" "FSTYPE" "MOUNTPOINT"
    printf "%s\n" "$all_details"
}


function usb_to_format(){
    # Check if the USB the user enters is plugged into the system
    show_usb_drives

   
    get_usb_devices=$(show_usb_drives | awk -v name="NAME" '$1 !~ name {devices = devices $1 " "} END {print devices}')

    names=$(printf "%s" "$get_usb_devices")
    message "USB(s) Found: [ $names]"

    echo "CAUTION. Type the chosen USB carefully"
    read -p "Enter USB: " device

    # Create an array with the USBs found 
    usb_devices=($get_usb_devices)

    for item in "${usb_devices[@]}"; do
        if [[ "$item" == "$device" ]]; then
            selected_usb="/dev/$device"
            return
        fi
    done

    alert "[!] Unknown USB: [$device]" && exit 1
}

function get_usb_name(){
    # Display the USBs found 

    show_usb_drives

    get_usb_devices=$(show_usb_drives | awk -v name="NAME" '$1 !~ name {devices = devices $1 " "} END {print devices}')
    # usb_devices=$(show_usb_drives | awk '{print $1}')

    if [[ "$get_usb_devices" == "" ]]; then 
        alert "[!] No USBs found" && exit 1
    fi

    display=$(printf "%s" "$get_usb_devices")
    if [[ -n "$display" ]];then
        message "USBs Found: [$display]"
    fi

    read -p "Enter USB: " device

    for item in "${usb_devices[@]}"; do
        if [[ "$item" =~ $device ]]; then
            selected_usb="/dev/$device"
        else
            alert [!] Unknow USB: "$device" && exit 1
            exit
        fi
    done

}

function format_usb(){
    # Create luksFS and format USB

    usb_to_format

    echo Encrypting ["$selected_usb"]
    sudo cryptsetup luksFormat "$selected_usb" 
    sudo cryptsetup luksOpen  "$selected_usb" encrypted_drive
    read -p "Enter the label name: " label
    sudo mkfs.ext4 -L "$label" /dev/mapper/encrypted_drive

    notify-send "🔒USB $label formated and encrypted"
    sudo cryptsetup luksClose encrypted_drive

}

function mount_usb(){
    # Mount the usb
    
    usb_to_format

    sudo cryptsetup luksOpen  "$selected_usb" encrypted_drive

    if [ ! -d "$MOUNT_DIR" ]; then
        sudo mkdir -p "$MOUNT_DIR"
        sudo chmod -R 775 "$MOUNT_DIR"
    fi

    sudo mount -t auto -o rw,nosuid,nodev,relatime /dev/mapper/encrypted_drive $MOUNT_DIR
    sudo chmod -R 775 "$MOUNT_DIR"
    notify-send "USB 💾 mounted" "USB is unlocked in $MOUNT_DIR"
}

function umount_usb(){
   # Unmount the USB 

    usb_to_format
    if [[ -n "$selected_usb" ]]; then
        sudo umount "$MOUNT_DIR" > /dev/null 2>&1
        if [[ $? -eq 0 ]]; then
            sudo cryptsetup luksClose encrypted_drive
            notify-send "🔒USB closed." "USB is now securely locked again."
            exit 0
        else
            alert "[!] No USB mounted"
            exit 1
        fi
    fi


}
function show_help(){
cat << EOF
    💾🔒💾 Utility to encrypt USB Devices

    Usage: usb_encrypt.sh 
        -f  format usb. Prepare the usb for encryption
        -m  mount usb
        -u  unmount usb
        -v  verbose output of the installed dependencies
        -h  show this help

    📄  version 1.0 - nisidabay 2023

EOF
}
#--- script begins here

opt_counter=0
while getopts ":hfmuv" option;do
  case $option in
    f) 
        format_usb
        (( opt_counter+=1 ))
        ;;
    m) 
        mount_usb
        (( opt_counter+=1 ))
        ;;
    u) 
        umount_usb
        (( opt_counter+=1 ))
        ;;
    h) 
        show_help
        (( opt_counter+=1 ))
        ;;
    v)
        verbose="v"
        (( opt_counter+=1 ))
        ;;
    \?) 
        echo  Invalid option
        show_help
        ;;
  esac
done

chk_dependencies "lsblk" "cryptsetup" "notify-send" "dunst"

if [[ $opt_counter == 0 ]];then
    show_help
fi
