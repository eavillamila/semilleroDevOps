#!/bin/bash

for file in file_salida/*
  do
    mv "$file" "${file}"-mv.txt
done

ls file_salida/ | tr "\t" "\n" | cat -n > salida.out
cat salida.out
