#!/usr/bin/env bash
#
# Create and encrypted ISO image.
#
# Dependencies: cryptsetup, losetup, umount, rm

# Debugging setup for bash
set -euo pipefail
################################################################################
# GLOBAL VARIABLES
################################################################################

# # Ansi color code global variables
# expand_bg="\e[K"
# blue_bg="\e[0;104m${expand_bg}"
# red_bg="\e[0;101m${expand_bg}"
#green_bg="\e[0;42m${expand_bg}"
green="\e[0;32m\033[1m"
# red="\e[0;31m\033[1m"
turquoise="\e[0;36m\033[1m"
# gray="\e[0;37m\033[1m"
# yellow="\e[1;93m\033[1m"
reset="\033[0m\e[0m"
#
OK='✔'
FAIL='✘'

function close_crypto_vault() {
    # Safely unmount the ext4 filesystem
    # if [ $OPEN_VAULT == "0" ];then
    # echo -e "[!] ${turquoise}El volumen no está abierto.$FAIL${reset}"
    # fi
    sudo umount /dev/mapper/volume1
    echo -e "[+] ${turquoise}Cerrando el volumen y borrando montajes. $OK${reset}"

    sudo cryptsetup luksClose volume1
    sudo rm -rf /media/datadisc
    #
    # 9.  Close up the encrypted LUKS container and clean up the loop device
    sudo losetup -d /dev/loop10
}
#
# 10. Burn the ISO file to disc
# growisofs -dvd-compat -Z /dev/sr0=image.iso
# or
# wodim dev=/dev/sr0 imagen.iso
#
# 11. Mount the disc
# sudo losetup /dev/loop10 /dev/sr0
# sudo cryptsetup -r luksOpen /dev/loop10 volume1
# sudo mount -t ext4 -o ro /dev/mapper/volume1 /media/datadisc
#
# 12. Unmount the disc
# sudo umount /dev/mapper/volume1
# sudo cryptsetup luksClose volume1
# sudo losetup -d /dev/loop10
close_crypto_vault
