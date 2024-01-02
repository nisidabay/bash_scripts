#!/bin/bash

# Entrada por teclado y almacenamiento en arrays.

# -a lee en un array
echo -e "Ingresa tres palabras: "
read -a  palabras

echo  "primera palabra: " "${palabras[0]}"
echo  "segunda palabra: " "${palabras[1]}"
echo  "tercera palabra: " "${palabras[2]}"
echo "Todos los elementos: " "${palabras[@]}"
echo "Todos los elementos: " "${palabras[*]}"
echo "Indices del array: " "${!palabras[@]}"
echo "Número de elementos: " "${#palabras[@]}"
echo "Número de elementos: " "${#palabras[*]}"
echo "Longitud del primer elemento: " "${#palabras[0]}"


