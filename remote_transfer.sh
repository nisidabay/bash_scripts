#!/usr/bin/bash
# Author: Carlos Lacaci Moya
# Description: Send files/folders over SCP
# Date: mié 15 dic 2021 21:30:26 CET
# Dependencies: sshpass, scp, nslookup

# Debugging setup for bash
set -euo pipefail
################################################################################ 
# GLOBAL VARIABLES
################################################################################
# Ansi color code global variables
expand_bg="\e[K"
green_bg="\e[0;42m${expand_bg}"
green="\e[0;32m\033[1m"
red="\e[0;31m\033[1m"
turquoise="\e[0;36m\033[1m"
gray="\e[0;37m\033[1m"
yellow="\e[1;93m\033[1m"
reset="\033[0m\e[0m"

REMOTE_HOSTS_FILE="$(pwd)/temp_scan"
SUBNET="192.168.1."
IP_SHORT=0 #Flag to control the size of IP address
DEPENDENCIES=(sshpass nmap nslookup)
declare -a LOCAL_HOSTS
OK='✔'
FAIL='✘'

################################################################################
# Cleaning temporary file "temp_scan"
trap rm_hosts_file SIGINT SIGTERM 

function check_localnetwork(){
# Check connectivity of the local host

    network=$(nslookup "$(hostname)" | awk -F ":" '$1 == "Address", $2 ~ /([0-9]+\.){3}/')
    if [[ -z $network ]];then
        echo -e "${gray}${red}[-] Local host is down!${reset}"
        exit 1
    fi
}

function get_remote_server_name(){
# Get the remote host name from IP

    msg="[!]The remote host does not exists. Check the IP address"

    name=$(nslookup -type=PTR "$1" | sed -ne '/name/p' | awk -F "=" '{print $2}')

    if [[ -z $name ]];then
        echo -e "${gray}${red}$msg${reset}" 
        exit 1
    fi

    echo -e "${gray}[+] Connecting ->: ${yellow}$name${reset}"
}

function is_ip_valid(){
# Check valid IP based on options: -e [short_ip] or -i [full_ip]

if [[ $IP_SHORT -eq 1 ]];then

        # IP: XXX.XXX.XXX.128
        msg="Only last IP octet with [-e] option"

        ip=$(echo "$1" | sed -nE "/^[0-9]{1,3}$/p")

        if [[ -z $ip ]];then
            echo -e "${gray}${red}[!]$msg${reset}" 
            exit 1
        fi

        ip=${SUBNET}$ip_ext
        ip_add=$ip
else
        # IP: 192.168.1.128
        msg="Only full IP address with [-i] option"

        ip=$(echo "$1" | sed -nE "/^([0-9]{1,3}\.){3}[0-9]{1,3}$/p")

        if [[ -z $ip ]];then 
            echo -e "${gray}${red}[!]$msg${reset}" 
            exit 2
        fi

        ip_add=$ip
fi
}

function check_program_dependencies(){
# Check for necessary binaries

    for prog in "${DEPENDENCIES[@]}"; do

        [[ -f "/usr/bin/$prog" ]] > /dev/null 2>&1
        if [ $? -ne 0 ];then
            echo -e "\t[-] $prog -> ${red}$FAIL${reset}"
            exit 1
        fi

    done
}

function show_help(){
# Usage
  echo -ne "${gray}${yellow}Transfer files or folders through ssh \n${reset}"
  echo
  echo -ne "${gray}The script must be executed in the folder where you want to send the files\n${reset}"
  echo
  echo -ne "${gray}If it is a folder must be executed one level up${reset}"
  echo 
  echo 
  echo -ne "${gray}Usage: remote_transfer.sh [OPTIONS]\n${reset}"
  echo
  echo -ne "${gray}\t -s [scan local hosts]\n${reset}"
  echo -ne "${gray}\t -e [remote host short ip]\n${reset}"
  echo -ne "${gray}\t -i [remote host full ip]\n${reset}"
  echo -ne "${gray}\t -d [remote host folder]\n${reset}"
  echo -ne "${gray}\t -f [files/folders to transfer to]\n${reset}"
  echo
  echo -ne "${red}\tExamples:\n${reset}"
  echo -ne "\tremote_transfer.sh -s\n"
  echo -ne "\tremote_transfer.sh -e 38 -d Downloads -f '*.py'\n"
  echo -ne "\tremote_transfer.sh -e 38 -d Downloads -f '*.py' -f '*.txt'\n"
  echo -ne "\tremote_transfer.sh -e 38 -d Downloads -f movie_1.mkv -f movie_2.mkv\n"
  echo -ne "\tremote_transfer.sh -i 192.168.1.38 -d Downloads -f '*.mkv' -f '\n"
  echo -ne "\tremote_transfer.sh -i 192.168.1.38 -d Downloads -f movie_1.mkv -f movie_2.mkv\n"
  echo -ne "\tremote_transfer.sh -i 192.168.1.38 -d Music -f /Movies\n"

  echo -ne "${yellow}@Carlos Lacaci Moya - 2021. v.1.0 ;)${reset}"
}


function transfer_files(){
# Transfer the files or folder

for ((i=0; i< ${#files[@]}; i++))
    do
        # File
        if [[ -f "$(pwd)/${files[$i]}" ]];then

            echo -e "[+] Sending file [${yellow}${files[$i]}${reset}] to [${yellow}$ip_add:/$host_folder${reset}]"
            sshpass -p 'PASSWORD_REMOVED' scp -CTr "${files[$i]}" nisidabay@"$ip_add":"${HOME}"/"${host_folder}" 

            echo -e "[+] Transfer complete${green} $OK${reset}\n"

        # Folder 
        elif [[ -d "$(pwd)/${files[$i]}" ]];then

            echo -e "[+] Sending folder [${yellow}$files${reset}] to [${yellow}$ip_add:/$host_folder${reset}]"

            sshpass -p 'PASSWORD_REMOVED' scp -CTr "${files[$i]}" nisidabay@"$ip_add":"${HOME}"/"${host_folder}" 

            echo -e "[+] Transfer complete${green} $OK${reset}\n"
        else
            msg="${gray}${red}[!] Folder or file does not exists. Check the name!${reset}"
            echo -e "$msg"
            exit 1

        fi
    done
}

function _remove_temp(){
# Remove temp file

    if [[ -f $REMOTE_HOSTS_FILE ]];then
        rm "$REMOTE_HOSTS_FILE"
    fi
}

# function get_hosts_from_file(){
# # Find Host and IP in the REMOTE_HOSTS_FILE
# 
    # for host in "${LOCAL_HOSTS[@]}";do
# 
         # HOST=$(awk -v host="$host" '$5 ~ host {print $5}' "$REMOTE_HOSTS_FILE")
         # 
         # if [[ "$HOST" == "" ]];then
             # echo -n -e "${gray}${red}[-] Host:$host is down${reset}\n"
         # else
             # IP=$(awk -v host="$host" '$5 ~ host {print $6}' "$REMOTE_HOSTS_FILE" | sed -e 's/[()]//g')
             # echo -n -e "${gray}\n[+] Host:$HOST IP:$IP is alive${reset}\n"
         # fi
    # done
# 
# # Call _remove_temp
# _remove_temp
# exit 0
# }

function scan_network(){
# Scan local network and create REMOTE_HOSTS_FILE
clear

# Checking connectivity
check_localnetwork

# Checking uid. No root will be asked for password
if [[ "$(id -u)" != "0" ]];then

    echo -e "${gray}${red}[!] Operation requires root privilegies${reset}"
    echo -e "${yellow}[+] Scanning local network, wait ...${reset}"
    
    sudo nmap -sn 192.168.1.0/24 | sed -n -e '/.*down.*/d' -e '/scan report for/p' > "$REMOTE_HOSTS_FILE"
fi

# Call functions
add_remote_hosts_found
# get_hosts_from_file
}

function add_remote_hosts_found(){
# Add hosts found to LOCAL_HOSTS 

    if [[ -f $REMOTE_HOSTS_FILE ]];then
            HOSTS=$(awk '{ print $5 }' "$REMOTE_HOSTS_FILE")
            for h in $HOSTS;do
                LOCAL_HOSTS=("${LOCAL_HOSTS[@]}" "$h")
            done
    else
            echo -e "${gray}${red}[-]File ($REMOTE_HOSTS_FILE) does not exist${reset}"
            echo -ne "${green}Usage: remote_transfer.sh -s [scan] to scan the network\n${reset}"
            exit 1
    fi

    rm_hosts_file
}

function rm_hosts_file(){
# Remove REMOTE_HOSTS_FILE

if [ -f "$REMOTE_HOSTS_FILE" ];then
   rm "$REMOTE_HOSTS_FILE" > /dev/null 2>&1
   exit 1
fi
}

opt_counter=0
while getopts ":hse:i:d:f:" option;do
  case $option in
    s) 
        #scan=$OPTARG
        scan_network
        ;;
    e) 
        # Only last octet
        ip_ext=$OPTARG;(( opt_counter+=1 ))
        (( IP_SHORT+=1 ))

        is_ip_valid "$ip_ext"
        ;;
    i) 
        # Full IP address
        IP_SHORT=0
        ip_add=$OPTARG;(( opt_counter+=1 ))
        is_ip_valid "$ip_add"
        ;;
    d)
        host_folder=$OPTARG;(( opt_counter+=1 ))
        ;;
    f)
        IFS=""
        files+=($OPTARG);(( opt_counter+=1 ))
        # echo "[*] DEBUG FLAG - Len args: ${#files[@]}"
        ;;
    h) 
        show_help
        ;;
    \?) 
        echo -e "${gray}${red}[-] Invalid option -$OPTARG${reset}"
        show_help
        ;;

    :) 
        echo -e "${gray}${red}[-] Missing value for the argument [-$OPTARG]${reset}"
        show_help
        ;;
  esac
done
shift $(( $OPTIND - 1 ))

# Save the IFS for using with f option an pass arguments with spaces
OLDIFS=$IFS
if [[ "$opt_counter" -ge 3 ]];then
    check_program_dependencies
    get_remote_server_name "$ip_add"
    # Change the IFS
    IFS=""
    transfer_files
    # Restore IFS
    IFS=$OLDIFS
else
    show_help
fi

