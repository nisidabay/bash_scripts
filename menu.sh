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

