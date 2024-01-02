#!/usr/bin/bash
################################################################################
#
#        /         # Purpose: Create a menu with tput
#        /         # Date: sáb 18 sep 2021 06:46:42 CEST
#        /          
#        /       	
# / ///   / ///   
# //   /  //   /  
# /    /  /    /  
# /    /  /    /  
# /    /  //   /  
# /    /  / ///   
#
#nisidabay@gmail.com                
#From: https://www.linuxcommand.org/lc3_adv_tput.php
###############################################################################
# tput_menu: a menu driven system information program

    BG_BLUE="$(tput setab 4)"
    BG_BLACK="$(tput setab 0)"
    FG_GREEN="$(tput setaf 2)"
    FG_WHITE="$(tput setaf 7)"

    # Save screen
    tput smcup

    function menu(){
        echo "Please Select:"

        echo "1. Display Hostname and Uptime"
        echo "2. Display Disk Space"
        echo "3. Display Home Space Utilization"
        echo "0. Quit"
    }

    # Display menu until selection == 0
    while [[ $REPLY != 0 ]]; do
      echo -n ${BG_BLUE}${FG_WHITE}
      clear
      menu
      read -p "Enter selection [0-3] > " selection
      
      # Clear area beneath menu
      tput cup 10 0
      echo -n ${BG_BLACK}${FG_GREEN}
      tput ed
      tput cup 11 0

      # Act on selection
      case $selection in
        1)  echo "Hostname: $HOSTNAME"
            uptime
            ;;
        2)  df -h
            ;;
        3)  if [[ $(id -u) -eq 0 ]]; then
              echo "Home Space Utilization (All Users)"
              du -sh /home/* 2> /dev/null 
            else
              echo "Home Space Utilization ($USER)"
              du -sh $HOME/* 2> /dev/null | sort -nr
            fi
            ;;
        0)  break
            ;;
        *)  echo "Invalid entry."
            ;;
      esac
      printf "\n\nPress any key to continue."
      read -n 1
    done

    ## Restore screen
    tput rmcup
