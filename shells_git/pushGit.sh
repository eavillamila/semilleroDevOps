#!/bin/bash

echo -e 'A continuación, se muestra el estado del repositorio local: \n'
git status
echo -e '\nPresiona ENTER para continuar...'
read -p ''

clear
echo -e 'Se agregan los archivos al entorno de prueba...\n'
git add .
echo -e '\nPresiona ENTER para continuar...'
read -p ''

clear
echo -e 'Se realiza el commit del repositorio...\n'
read -p 'Ingresa el comentario (Sugerencia - En la forma "#Comment"): ' comment
git commit -m "$comment"
echo -e '\nPresiona ENTER para continuar...'
read -p ''

clear
echo -e 'Se realiza el push hacia el repositorio remoto...\n'
read -p 'Ingresa el nombre de la rama: ' rama
git push origin "$rama"
echo -e '\nPresiona ENTER para continuar...'
read -p ''

git status
echo -e '\nPresiona ENTER para continuar...'
read -p ''

clear
unset comment
unset rama