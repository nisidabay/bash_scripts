#!/usr/bin/bash
function help(){
    echo "Description of the program"
    echo ""
    echo "Usage: program [OPTION] [INDEX]"
    printf "  %-20s\t%-54s\n" \
        "-h, --help, help" "Print his help."\
        "-l, --list, list" "List all installed features."

}
help
