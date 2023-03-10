#!/bin/bash

mkdir file_salida/

while IFS= read -r line
  do
    touch file_salida/"$line"
done < entrada.in

ls file_salida/  > salida.out

cat -n salida.out
