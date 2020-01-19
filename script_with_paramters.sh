#!/bin/bash

NAME=$1
LASTNAME=$2
MOSTRAR=$3

if [ "$MOSTRAR" = "true" ]; then
   echo "Hola, $NAME $LASTNAME"
else
   echo "Para mostrar el nombre completo, debe seleccionar la variable MOSTRAR"
fi
