#!/bin/bash
# 
# Types of argumetns

echo 'Entendiendo el paso de argumentos'
# This line simply echoes a string to the terminal, which means "Understanding the passing of arguments".

clear
# This command clears the terminal screen.

echo 'Todos los argumentos $*->' "$*"
# Echoes all the arguments passed to the script as a single string. $* expands to all the positional parameters, starting from $1.

echo 'Numero de argumentos $# ->' "$#"
# Echoes the number of arguments passed to the script. $# is a special parameter in Bash that expands to the number of positional parameters in decimal.

echo 'Argumentos posicionales $@ ->' "$@"
# Echoes all the arguments passed to the script, each as a separate string. $@ expands to all the positional parameters, but unlike $*, each parameter is a separate word.

echo 'nombre del script $0 ->' "$0"
# Echoes the name of the script itself. $0 is a special parameter in Bash that expands to the name of the script.

echo 'primer argumento $1 -> ' "$1"
# Echoes the first argument passed to the script. $1 is a positional parameter that expands to the first argument.

echo 'segundo argumento $2 -> ' "$2"
# Echoes the second argument passed to the script. $2 is a positional parameter that expands to the second argument.
