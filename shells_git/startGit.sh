#!/bin/bash

clear
read -p '¿Deseas clonar un repositorio? (y/n): ' option1
if [ $option1 = y ] || [ $option1 = Y ]; then
    read -p 'Escribe la URL HTTPS o SSH para clonar el repositorio: ' url
    git clone $url
    echo -e '\nPresiona ENTER para continuar...'
    read -p ''
    clear
fi

url="$(echo "${url##*/}")"
cd "$(echo "${url%.*}")"
read -p '¿Deseas realizar las configuraciones iniciales del repositorio? (y/n): ' option1
if [ $option1 = y ] || [ $option1 = Y ]; then
    echo -e 'Configuración básica del repositorio...\n'
    read -p 'Ingresa el nombre de usuario: ' user
    read -p 'Ingresa el correo GitHub del usuario: ' email

    git config --global user.name $user
    git config --global user.email $email
    git config --global core.autocrlf false
    clear

    read -p '¿Quieres desactivar la validación de los certificados SSL? (y/n): ' option1
    if [ $option1 = y ] || [ $option1 = Y ]; then
        git config --global http.sslVerify false
    fi
fi

echo -e 'A continuación, se muestra el estado actual del repositorio local y las ramas disponible:\n'
git status
echo -e '\nRamas disponibles:'
git branch -r

echo -e '\n'
read -p '¿Quieres cambiar de rama? (y/n): ' option1
if [ $option1 = y ] || [ $option1 = Y ]; then
    read -p 'Ingresa el nombre de la rama: ' rama
    git checkout $rama
fi

clear
unset option1
unset url
unset rama
unset user
unset rama