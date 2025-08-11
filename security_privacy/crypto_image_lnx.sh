#!/usr/bin/bash
# Author: Carlos Lacaci Moya
# Create a valult like LUKS encrypted image
# Date: lun 08 ago 2022 18:15:41 CEST
#
# Observations
# ------------

# I tried to create an encrypted luks Filesystem using mkfs.exfat. The problem
# was I couldn't change the ownership of the directory where the image was mounted
# for the "current user", and all the user's operations such as create and delete
# files inside the directory had to be done using "sudo".
# I solved the problem using mkfs.ext4


# Debugging setup for bash
set -euo pipefail


# Ansi color code global variables
green="\e[0;32m\033[1m"
red="\e[0;31m\033[1m"
turquoise="\e[0;36m\033[1m"
yellow="\e[1;93m\033[1m"
reset="\033[0m\e[0m"
 
OK='✔'
FAIL='✘'

# Working directory
declare -g PWD=$(pwd)

# Size of the image
declare -g SIZE
declare -g INITIAL

# Default /dev/loop10
declare -g last_loop_device_used="/dev/loop10"


function get_image_name(){
    # Get and return the image name

    read -p "Write the name of the image (Ex: data.iso): " image

    if [ -n "$image" ];then
        echo "$image"
    fi
}

function ask_user_for_image(){
    # Ask user for image name

    echo "Do you want to create a new encrypted image?"
    read -p "[Y]es/[N]o: " answer

    while true;do
      case $answer in
       [yY]* ) break;;

       [nN]* ) 
           echo -e "[!] ${red}Aborting $FAIL${reset}"
           exit 1;;

       * ) echo -e "${red}[!] Enter Y or N, please.${reset}";
           ask_user_for_image;;
      esac
    done
}

function ask_for_image_size(){
    # Ask for the size of the image

    echo "Write the size of the image in number. You will be asked for (M)egabytes or (G)igabytes later"
    read -p "Enter the size (4, 8, 16 ...): " SIZE

    while [ -z "$SIZE" ];do
        echo "Write the size of the image in number. You will be asked for (M)egabytes or (G)igabytes later"
        read -p "Enter the size (4, 8, 16 ...): " SIZE
    done

    echo -e "The size of the image is ${green}$SIZE${reset}. Next you will choose Megabytes or Gigabytes"
    read -p "Is that correct? [Y]es/[N]o/[C]ancel: " answer

    while true;do
      case $answer in
       [yY]* ) break;;

       [nN]* ) 
           ask_for_image_size;;

       [cC]* )
           echo -e "[!] ${red}Aborting the script${FAIL}${reset}";
           exit 1;;

       * ) echo -e "${red}[!] Enter [Y]es or [N]o, please.${reset}";
           ask_user_for_image;;
      esac
    done
}

function check_available_loop_devices(){
# Check if last_loop_device_used=/dev/loop10 is available

last_loop_device_used=$1

# Stores the loop devices in use by the system
declare -a loop_devices_in_use

while read line;do
    loop_devices_in_use+=("$line")
done < <(losetup -a | cut -d: -f1 | sort)

for device in "${loop_devices_in_use[@]}";do
    if [ "$device" = "$last_loop_device_used" ];then
        echo -e "[!] Default device ${red}[$last_loop_device_used]${reset} is already taken"
        read -p "Choose the next one (/dev/loop[number]): " selected_device

        last_loop_device_used=$selected_device
    fi
done

# Update last_loop_device_used
sed -i.bk '/last_loop_device_used/d' ~/.bashrc
echo "export last_loop_device_used=$last_loop_device_used" >> ~/.bashrc
source ~/.bash_profile
}

function create_crypto_vault(){
    # Create encrypted image

    ask_user_for_image

    # Get the image name
    image=$(get_image_name)
    if [ -z "$image" ];then
        echo -e "[!] ${red}Aborting. No image name provided${reset}"
        exit 1
    fi


    echo "[!] You will be prompted for root password several times"
    read -p "-> Press Enter" 

    ask_for_image_size

    if [ $SIZE -gt 0 ];then
        read -p "M(megabytes) or G(gigabytes)?. Enter initial in uppercase: " INITIAL
        while [[ ! "$INITIAL" =~ [MG] ]];do
            read -p "M(megabytes) or G(gigabytes)?. Enter initial in uppercase: " INITIAL
        done
    fi

    if [ -n "$INITIAL" ];then
        echo -e "[!] About to create an image of ${green}${SIZE}${INITIAL}${reset} in size"
        truncate --size ${SIZE}${INITIAL} ${image}
    fi

    # echo "Image should be created by now"

    check_available_loop_devices "$last_loop_device_used"

    # Get the image without extension if provided
    volume=${image%.*}

    # Create the image and format it
    sudo losetup $last_loop_device_used "${image}"
    sudo cryptsetup luksFormat "$last_loop_device_used"
    sudo cryptsetup luksOpen "$last_loop_device_used" "$volume"
    sudo mkfs.ext4 /dev/mapper/$volume


            
    # Create the mount point
    if [[ ! -d /tmp/"$image" ]];then

        echo -e "[+] Creating mount point"
        mkdir /tmp/"$image"

        # Mount the image and give user rw ownership 
        sudo mount /dev/mapper/"$volume" /tmp/"$image" 
        sudo chown -R $(whoami) /tmp/"$image"

    fi

    echo "--------------------------------------------------------------"
    echo -e "[+] Image ${green}[${image}]${reset} created ${green}$OK${reset}"
    echo -e "[+] Mount the image with ${green} -m flag${reset} to add files"
    echo -e "[!] Remember. The size must be less than ${green}${SIZE}${INITIAL} in size${reset}"
    echo "--------------------------------------------------------------"

    # Close the image
    close_crypto_vault "$volume"
}

function close_crypto_vault(){
    # Unmount the image and delete the mount point

    volume=$1
    echo -e "[+] Closing the image ${green}[/tmp/${image}] $OK${reset}"
    cd

    # The image is open so unmount, close and delete mount point
    sudo umount /dev/mapper/"$volume"
    sudo cryptsetup luksClose "$volume"
    echo -e "[+] Deleting mount point${green}[/tmp/${image}] $OK${reset}"
    sudo rm -rf /tmp/"$image"
    sudo losetup -d "$last_loop_device_used"
}

function mount_image(){
    # Mount the image

    image=$(get_image_name)
    if [ -z "$image" ];then
        echo -e "[!] ${red}Aborting. No image name provided${reset}"
        exit 1
    fi

    # Image name without extension if provided
    volume=${image%.*}

    # Check if default device is already taken
    check_available_loop_devices "$last_loop_device_used"

    if [[ -e "$image" ]]; then

        # echo Mount point does not exist
        if [[ ! -d /tmp/"$image" ]];then
            echo "[+] Creating mount point"
            mkdir /tmp/"$image"
        fi

        echo -e "[+] Mounting the image ${green}[${image}] ${reset}"
        read -p "Press Enter ..."


        # Get default loop device or the new provided
        device=$last_loop_device_used

        # Open the image and mount it
        sudo losetup "$device" "${image}" >/dev/null 2>&1 || echo -e "[!]${yellow}[${image}]${reset}${red} is protected. Unprotect it first with the -w flag${reset}" 

        if [ $? -eq 0 ];then
            sudo cryptsetup luksOpen "$device" "$volume" >/dev/null 2>&1 
            sudo mount /dev/mapper/"$volume" /tmp/"$image" >/dev/null 2>&1 
            sudo chown -R $(whoami) /tmp/"$image"
        else
            exit 1
        fi

        echo  "------------------------------------------"
        echo -e "[+] Image mounted on: ${green}[/tmp/$image]${reset} $OK${reset}"
        echo -e "[+] Unmount the image with ${green}-u flag${reset}"
        echo  "------------------------------------------"
    else
        echo -e "${red}-----------------------------------------------${reset}"
        echo -e "[!] Image ${red}not found${reset} or ${red}wrong type${reset}. Check again"
        echo -e "${red}-----------------------------------------------${reset}"
    fi
}

function return_device(){
# Output the contents of mounted devices and images
# losetup -a 

# Get the devices and image associated to them

# This is the format to parse:
# /dev/loop11: []: (/home/nisidabay/Descargas/Refactor/data.iso)
# /dev/loop10: []: (/home/nisidabay/Descargas/Refactor/caca.iso)

declare -A mounted_devices

image="$1"
while read line;do

    device_field=$(echo "$line" | awk -F":" '{print $1}')
    image_field=$(echo "$line" | awk -F":" '{print $3}')

    # Get only loop10 stripping out /dev/
    d=${device_field##*/}
    
    # Get only image base name without extension
    image_field=$(echo $image_field | tr -d '()')
    i=${image_field##*/}
    i=${i%%.iso}

    # Add to array
    mounted_devices[$d]=$i

done < <(sudo losetup -a)

for device in "${!mounted_devices[@]}";do
        if [ "$image" = "${mounted_devices[$device]}" ];then
            echo "$device"
        fi
done
}

function umount_image(){
    # Unmount the image
    image=$(get_image_name)

    if [ -e "$image" ]; then

        # Image name without extension if provided
        volume=${image%.*}

        # Get /dev/loop number where the image is mounted
        device_number=$(return_device "$volume")
        if [[ -n $device_number ]];then

            cd ${PWD}
            sudo umount /dev/mapper/"$volume" 
            sudo cryptsetup luksClose /dev/mapper/"$volume" 
            sudo losetup -d /dev/"$device_number" 
            sudo rm -rf /tmp/"$image" 

            echo  "--------------------------------------------"
            echo -e "[+] The image ${green}[$image] ${reset}is closed"
            echo  "--------------------------------------------"
        else
            echo  "--------------------------------------------"
            echo -e "[+] The image ${green}[$image] ${reset}is not mounted"
            echo  "--------------------------------------------"

        fi
    else
        echo -e "${red}-----------------------------------------------------${reset}"
        echo -e "[!] Image ${red}not mounted${reset} or ${red}mispelled name${reset}. Check again"
        echo -e "${red}-----------------------------------------------------${reset}"

    fi
}
#TODO:CHECK THIS FUNCTION
function list_mounted(){
    # List mounted devices

local -A images_on_devices
devices=$(sudo losetup -a)

# Check if there are /dev/loop devices

if [ -n "$devices" ];then
    while read line;do
        device_field=$(echo "$line" | awk -F":" '{print $1}')
        image_field=$(echo "$line" | awk -F":" '{print $3}')

        # Get only loopNum stripping out /dev/
        d=${device_field##*/}
        
        # Get only image base name without extension
        image_field=$(echo $image_field | tr -d '()')
        img=${image_field##*/}
        #img_noext=${img%%.iso}

        # Add to array
        images_on_devices[$d]="$img"

    done < <(sudo losetup -a)

    for device in "${!images_on_devices[@]}";do
            echo -e "${red}Image:${reset}${green}${images_on_devices[$device]}${reset}${yellow} using ${reset}${green}/dev/$device${reset}"
    done
else
    printf "${red}[!] No /dev/loop devices in use${reset}\n"
fi
}


function force_umount(){
    # Force removal of /dev/loop
    read -p "[+] Enter dev/loop you want to forcebly unmount: " device_number
    
    device_number=${device_number##*/}

    if lsblk | grep "$device_number";then
        sudo losetup -d /dev/"${device_number}" 
        sudo dmsetup remove -f /dev/"${device_number}" 
        echo -e "${red}Closing${reset}${yellow} [/dev/$device_number]${reset} $OK${reset}"
    else
        echo -e "${red}[!] /dev/${device_number} does not exist"
        exit 0
    fi
    # Repeat until showing the /dev/ ... does not exist message
    force_umount
}

function open_shell(){
    # Opens a shell

    echo "[+] Opening a shell"
    echo -e "[+] Press ${green}Enter${reset} to open it and type ${green}exit${reset} to leave"
    read -p ""
    bash && cd ${PWD}
}

function leave(){
    # Restore .bashrc and delete last_loop_device_used

        echo -e "[!] ${green}Leaving${reset} and ${green}cleaning ...${reset}"
        sed -i.bk '/last_loop_device_used/d' ~/.bashrc
        exit 0
}

function mk_image_ro(){
    # Make image read-only

    echo -e "[!] ${red}Before continue make sure the image is not mounted.${reset}"
    read -p "Do you want to make the protect the image?[Y]es/[N]o: " answer

    while [ -n "$answer" ];do
      case $answer in
       [yY]* ) 
            image=$(get_image_name)
            chk_before_ro "$image"
            # sudo chattr +i "$image"
            break;;

       [nN]* ) 
           break;;
      esac
    done
}
function mk_image_rw(){

    # Make image writeable
    # TODO

    echo -e "[!] ${red}Before continue make sure the image is not mounted.${reset}"
    read -p "Do you want to unprotect the image?[Y]es/[N]o: " answer
    while [ -n "$answer" ];do
      case $answer in
       [yY]* ) 
            image=$(get_image_name)
            chk_before_rw "$image"
            # sudo chattr +i "$image"
            break;;

       [nN]* ) 
           break;;
      esac
    done
}
function chk_before_ro(){
    # Check that the image is not mounted
    
    image=$1
    # Get the image without extension 
    image_noext=${image%.*}

    echo -e "[+]${green} Checking that image is not mounted${reset}"
    get_images=$(list_mounted)

    for img in ${get_images};do
        if [[ "$img" =~ $image_noext ]];then
            echo -e "[!] ${red}Aborting. The image${reset} [${yellow}$image${reset}]${red} is mounted${reset}"
            echo -e "[!] ${red}Unmount the image with the -u flag${reset}"
            exit 1
        fi
    done
    
    echo -e "[+] The image is not mounted ${green}$OK${reset}"
    read -p "Do you want to continue?[Y]es/[N]o: " response


    while [ -n "$response" ];do
      case $answer in
       [yY]* ) 
            echo "image is $PWD/$image"
            sudo chattr +i "$PWD/$image"
            break;;

       [nN]* ) 
            echo "Exiting"
            exit 1
            break;;

      esac
    done

}

function chk_before_rw(){
    # Check that the image is not mounted
    
    image=$1
    # Get the image without extension 
    image_noext=${image%.*}

    echo -e "[+]${green} Checking that image is not mounted${reset}"
    get_images=$(list_mounted)

    for img in ${get_images};do
        if [[ "$img" =~ $image_noext ]];then
            echo -e "[!] ${red}Aborting. The image${reset} [${yellow}$image${reset}]${red} is mounted${reset}"
            exit 1
        fi
    done
    
    echo -e "[+] The image is not mounted ${green}$OK${reset}"
    read -p "Do you want to continue?[Y]es/[N]o: " response


    while [ -n "$response" ];do
      case $answer in
       [yY]* ) 
            echo "image is $PWD/$image"
            sudo chattr -i "$PWD/$image"
            break;;

       [nN]* ) 
            echo "Exiting"
            exit 1
            break;;

      esac
    done

}
function show_help(){
# Usage
  echo -ne "${green}Create an encrypted iso image\n${reset}"
  echo
  echo -ne "Usage: ${green}crypto_image.sh ${reset}[OPTIONS]\n"
  echo
  echo -ne "\t -h ${green}[show help]\n${reset}"
  echo -ne "\t -c ${green}[create image]\n${reset}"
  echo -ne "\t -m ${green}[mount image]\n${reset}"
  echo -ne "\t -u ${green}[unmount image]\n${reset}"
  echo -ne "\t -f ${green}[unmount device]\n${reset}"
  echo -ne "\t -l ${green}[list mounted devices]\n${reset}"
  echo -ne "\t -r ${green}[protect the image]\n${reset}"
  echo -ne "\t -w ${green}[unprotect the image]\n${reset}"
  echo -ne "\t -q ${green}[quit and clean]\n${reset}"
  echo

  echo -e "${green}@Carlos Lacaci Moya - 2021. v.1.1 ;)${reset}"
}

counter=0
while getopts ":hclmurwfq" option;do
  case $option in
    c) 
        counter=$( ( counter+=1 ) )
        create_crypto_vault;

        ;;

    m)  
        counter=$( ( counter+=1 ) )
        mount_image;
        ;;

    u)  
        counter=$( ( counter+=1 ) )
        umount_image;
        ;;

    f)  
        counter=$( ( counter+=1 ) )
        force_umount;
        ;;

    l)  
        counter=$( ( counter+=1 ) )
        list_mounted;
        ;;

    r)  
        counter=$( ( counter+=1 ) )
        mk_image_ro;
        ;;
        
    w)  
        counter=$( ( counter+=1 ) )
        mk_image_rw;
       ;;

    q)  
        counter=$( ( counter+=1 ) )
        leave; 
        ;;
    h) 
        counter=$( ( counter+=1 ) )
        show_help
        ;;
    :) 
        show_help
        ;;

  esac
done
shift $(( $OPTIND - 1 ))

if [ "$counter" = 0 ];then
    show_help
fi

