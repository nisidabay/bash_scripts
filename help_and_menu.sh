#!/usr/bin/bash
#
# Help and menu template

function show_help(){
cat << EOF
🎶 💾 🔒💾 Utility to encrypt USB Devices

        Usage: usb_encrypt.sh 
            -f format usb
            -m mount usb
            -u umount usb
            -h show this help
    📄  version 1.0 - nisidabay 2023

EOF
}

opt_counter=0
while getopts ":hb:e:v" option;do
  case $option in
    b) 
        rate=${OPTARG:-$rate}
        do_set_bitrate $rate
        (( opt_counter+=1 ))
        ;;
    e) 
        ext=${OPTARG:-$ext}
        (( opt_counter+=1 ))
        ;;
    v) 
        verbose=true
        (( opt_counter+=1 ))
        ;;
    h) 
        show_help
        (( opt_counter+=1 ))
        ;;
    \?) 
        echo  Invalid option
        show_help
        ;;
    *)
        echo Missing option argument
        show_help
        ;;
  esac
done

if [[ $opt_counter != 1 ]];then
    show_help
fi
