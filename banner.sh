#!/usr/bin/bash
#Colours
# Banner template
declare -r greenColour="\e[0;32m\033[1m"
declare -r endColour="\033[0m\e[0m"
declare -r redColour="\e[0;31m\033[1m"
declare -r blueColour="\e[0;34m\033[1m"
declare -r grayColour="\e[0;37m\033[1m"
function banner(){
    echo -e "${greenColour}
                      .
                   %%%%%%%.
               %%%%%%.  %%%%%%.
          %%%%%%           *%%%%%%.
       %%%%%                   .%%%%%%
       %%%%%%%%               %%%%%%%%
       %%   %%%%%%%      .%%%%%%%  %%%
       %%       #%%%%%%%%%%%#      %%%    ${endColour}${grayColour}htbExplorer - HackTheBox Terminal Client${endColour}${greenColour}
       %%           %%%%#          %%%    ${endColour}${blueColour}\t\t\t     by S4vitar${endColour}${redColour} <3${endColour}${greenColour}
       %%            %%%           %%%
       %%            %%%           %%%
       %%%%%         %%%          %%%%
         %%%%%%%     %%%     %%%%%%.
             #%%%%%%%%%%%%%%%%%
                  %%%%%%%%#
                      .${endColour}\n"
    for _ in $(seq 1 80); do echo -ne "${redColour}-"; done; echo -ne "${endColour}"
}
banner
