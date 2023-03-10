#!/bin/bash

while IFS= read -r line
  do
    rm file_salida/"$line"
done < <(cat entrada.in | grep $1)

ls file_salida/ | tr "\t" "\n" | cat -n > salida.out
cat salida.out
