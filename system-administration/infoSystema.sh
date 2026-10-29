#!/usr/bin/env bash
#
# Display system information.
#
# Dependencies: none
#

clear
echo "Información del sistema"
echo
echo "Estado de la memoria ram"
free
echo
echo "Uso del disco duro"
echo
df -h
echo
echo "Versión del kernel"
echo
cat /proc/version
echo
echo "Versión del sistema operativo"
cat /etc/issue
