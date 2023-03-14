#!/bin/bash

# Limpiar terminal
clear

# Mensaje de bienvenida
echo -e '\e[0;32m******************************************************************'
echo '*   Bienvenido al menú de Adminsitración del Sistema Operativo   *'
echo '******************************************************************'
echo -e '\n'
echo 'Elaborado por: Edward Alonso Villamil Avellaneda'
echo -e 'Semillero DevOps - Banco Popular - AOS\e[m'
echo -e '\n'

# Opciones del menú
echo 'Aquí puedes realizar las siguientes acciones de administración: '
echo '1) Cambiar el nombre del servidor.'
echo '2) Cambiar partición de discos.'
echo '3) Cambiar IP del servidor'
echo '4) Cambiar tabla del Host'
echo '5) Agregar permisos de Firewall.'
echo '6) Editar DNS Server.'
echo '7) Configurar proxy.'
echo '8) Instalar Docker.'
echo '0) Salir.'

echo -e '\n'
read -p 'Ingrese el número de la opción deseada: ' option

while [ $option -ne 0 ] || [ $option != '0' ]; do

    case $option in
        0)
            ;;
        1)
            clear
            echo 'Habilitando el preserve hostname...'
            if [ -n "$(cat /etc/cloud/cloud.cfg | grep "#preserve_hostname: false")" ]; then
                sed -i 's/#preserve_hostname: false/preserve_hostname: true/' /etc/cloud/cloud.cfg
            elif [ -n "$(cat /etc/cloud/cloud.cfg | grep "preserve_hostname: false")" ]; then
                sed -i 's/preserve_hostname: false/preserve_hostname: true/' /etc/cloud/cloud.cfg
            fi

            read -p 'Por favor ingresa el nuevo Hostname:   ' hostname

            sudo hostnamectl set-hostname "$hostname"
            echo -e 'El Hostname del servidor ha sido cambiado por: ' "\e[0;32m$hostname\e[m"

            echo -e '\nPresiona ENTER para regresar al menú principal...'
            read -p ''
            unset hostname
            clear
            ;;
        2)
            clear

            echo 'Esta opción de partición  requiere de algunas acciones manueales.'
            echo 'Para realizar los primeros pasos debes instalar la herramienta GParted.'
            #echo 'Si aún no la has instalado, sal, ejecuta el siguiente comando y vuelve a ingresar al menú'
            #echo -e 'Comando de instalacion GParted: \e[0;32msudo apt update && sudo apt install gparted\e[m\n'

            read -p '¿Desea iniciar la herramienta de partición de Discos (y/n): ' option1
            if [ $option1 = y ] || [ $option1 = Y ]; then
                #sudo apt update
                sudo apt install gparted -y
                sudo -E gparted
            fi

            echo -e '\nPresiona ENTER para mostrar el listado de discos y particiones...'
            read -p ''
            clear
            echo -e "\n##################################################"
            df -h
            echo -e "\n##################################################\n"
            sudo fdisk -l
            echo -e "\n##################################################\n"
            
            read -p '¿Deseas montar una partición en el servidor? (y/n): ' option1
            if [ $option1 = y ] || [ $option1 = Y ]; then
                read -p 'Escribe el nombre de la partición que deseas montar: ' Particion
                read -p 'Ingresa el nombre de la carpeta sobre la que deseas montar la partición en la forma "/Folder": ' Pfolder
                sudo mkdir -p $Pfolder
                unset option1
                read -p '¿Desea convertirlo en un volumen persistente? (y/n): ' option1
                if [ $option1 = y ] || [ $option1 = Y ]; then
                    sudo chown -R $(whoami):$(whoami) $Pfolder
                    echo -e '\nAgregando la partición en el archivo /etc/fstab para montar al inicio del servidor...'
                    sudo sed -i "$(echo '$a' $Particion $Pfolder 'ext4 defaults     0   0')" /etc/fstab
                    echo -e '\nSe ha agregado la partición: \e[0;32m' "$Particion" '\e[m'
                fi
                sudo mount $Particion $Pfolder
                echo 'Partición montada.'
                echo -e '\nPresiona ENTER para continuar...'
                read -p ''
            fi

            clear
            unset option1
            unset Particion
            unset Pfolder
            ;;
        3)
            clear
            echo 'A continucación se listan las interfaces de Red disponibles: '
            echo "$(ifconfig -s)"
            echo -e '\n'
            read -p 'Ingresa el nombre de la interfaz deseada:  ' Iface
            read -p 'Ingresa la nueva IP del servidor:  ' Ip
            read -p 'Ingresa la máscara de red en la forma 255.255.255.255:  ' Netmask
            
            sudo ifconfig "$Iface" "$Ip" netmask "$Netmask"

            echo '\e[0;32mSe ha cambiado la IP de la interface de red ' "$Iface" '\e[m'

            unset Ip
            unset Iface
            unset Netmask
            clear
            ;;
        4)
            clear
            echo '¿Qué quieres hacer?'
            echo '1) Ver la tabla de Hosts.'
            echo '2) Adicionar un nuevo Host a la tabla.'
            echo '3) Eliminar un Host de la tabla.'
            echo '4) Modificar un Host de la tabla.'
            echo '0) Regresar al menú principal.'

            echo -e '\n'
            read -p 'Ingrese el número de la opción deseada: ' option1

            while [ $option1 -ne 0 ] || [ $option1 != '0' ]; do
                case $option1 in
                0)
                    ;;
                1)
                    clear
                    cat /etc/hosts
                    echo -e '\nPresiona ENTER para regresar al menú...'
                    read -p ''
                    clear
                    ;;
                2)
                    clear
                    read -p 'Ingresa la IP del nuevo Host:  ' Ip
                    read -p 'Ingresa el nuevo Host:  ' Host
                    if [ -n "$(cat /etc/hosts | grep "$Ip")" ]; then
                        echo 'La IP ingresada ya está registrada en la tabla de Hosts.'
                    else
                        sudo sed -i "$(echo '1i' $Ip $Host)" /etc/hosts
                        echo -e '\nSe ha agregado el Host: \e[0;32m' "$Host" : "$Ip" '\e[m'
                    fi

                    echo -e '\nPresiona ENTER para regresar al menú...'
                    read -p ''
                    clear
                    unset Ip
                    unset Host
                    ;;
                3)
                    clear
                    read -p 'Ingresa la IP o el Host a eliminar:  ' IpHost
                    if [ -n "$(cat /etc/hosts | grep "$IpHost")" ]; then
                        sudo sed -i "/$IpHost/d" /etc/hosts
                        echo -e '\nSe ha eliminado la IP o Host: \e[0;32m' "$IpHost" '\e[m'
                    else
                        echo 'La IP o Host no está registrada en la tabla de Hosts.'
                    fi

                    echo -e '\nPresiona ENTER para regresar al menú...'
                    read -p ''
                    clear
                    unset IpHost
                    ;;
                4)
                    clear
                    read -p 'Ingresa la IP del nuevo Host:  ' Ip
                    read -p 'Ingresa el nuevo Host:  ' Host
                    if [ -n "$(cat /etc/hosts | grep "$Ip")" ]; then
                        sudo sed -i "/$Ip/d" /etc/hosts
                    elif [ -n "$(cat /etc/hosts | grep "$Host")" ]; then
                        sudo sed -i "/$Host/d" /etc/hosts
                    else
                        echo 'La IP y Host no están registradas en la tabla de Hosts.'
                    fi
                    sudo sed -i "$(echo '1i' $Ip $Host)" /etc/hosts
                    echo -e '\nSe ha agregado el Host: \e[0;32m' "$Host" : "$Ip" '\e[m'

                    echo -e '\nPresiona ENTER para regresar al menú...'
                    read -p ''
                    clear
                    unset Ip
                    unset Host
                    ;;
                *)
                    clear
                    echo -e '\e[31mLa opción que ingresaste es incorrecta.\e[m'
                    ;;
                esac

                echo '¿Qué quieres hacer?'
                echo '1) Ver la tabla de Hosts.'
                echo '2) Adicionar un nuevo Host a la tabla.'
                echo '3) Eliminar un Host de la tabla.'
                echo '4) Modificar un Host de la tabla.'
                echo '0) Regresar al menú principal.'

                echo -e '\n'
                read -p 'Ingrese el número de la opción deseada: ' option1
            done

            clear
            unset option1
            ;;
        5)
            clear
            echo 'Verificando instalación de vsftpd...'
            if [ -z "$(sudo systemctl is-enabled vsftpd | grep "enabled")" ]; then
                echo -e 'Instalando el servicio vsftpd...\n'
                sudo apt update && sudo apt install vsftpd -y
            else
                echo -e 'El servicio vsftpd ya está instalado.\n'
            fi
            if [[ -n "$(sudo ufw status | grep "inactive")" ]]; then
                echo -e '\nHabilitando el servicio ufw...\n'
                echo 'Responde "yes" a la siguiente pregunta, tecleado "y" (El servicio ssh no se deshabilitará).'
                sudo ufw enable
            else
                echo -e '\nEl servicio ufw ya está habilitado.\n'
            fi
            echo -e '\nRevisando el estado del servicio'
            sudo ufw status
            sudo ufw allow ssh
            sudo ufw allow 22
            echo -e '\n'
            read -p 'Presiona ENTER para continuar con las opciones de Firewall...'

            clear
            echo '¿Qué quieres hacer?'
            echo '1) Agregar un puerto TCP.'
            echo '2) Agregar un puerto UDP.'
            echo '3) Habilitar un rango de puertos TCP.'
            echo '4) Habilitar un rango de puertos UDP.'
            echo '0) Regresar al menú principal.'

            echo -e '\n'
            read -p 'Ingrese el número de la opción deseada: ' option1

            while [ $option1 -ne 0 ] || [ $option1 != '0' ]; do
                case $option1 in
                0)
                    ;;
                1)
                    clear
                    echo ' Listado de Puertos Habilitados:'
                    sudo ufw status

                    read -p "Ingrese el puerto TCP que desea habilitar: " Port

                    sudo ufw allow $Port/tcp

                    echo -e '\nEl puerto ' "$Port" ha sido habilitado.
                    sudo ufw status | grep "$Port"

                    echo -e '\nPresiona ENTER para regresar al menú...'
                    
                    clear
                    unset Port
                    ;;
                2)
                    clear
                    echo ' Listado de Puertos Habilitados:'
                    sudo ufw status

                    read -p "Ingrese el puerto UDP que desea habilitar: " Port

                    sudo ufw allow $Port/udp

                    echo -e '\nEl puerto ' "$Port" ha sido habilitado.
                    sudo ufw status | grep "$Port"

                    echo -e '\nPresiona ENTER para regresar al menú...'
                    
                    clear
                    unset Port
                    ;;
                3)
                    clear
                    echo ' Listado de Puertos Habilitados:'
                    sudo ufw status

                    read -p "Ingrese el rango de puertos TCP que desea habilitar (inicial:final): " Port

                    sudo ufw allow $Port/tcp

                    echo -e '\nLos puertos ' "$Port" han sido habilitados.
                    sudo ufw status | grep "$Port"

                    echo -e '\nPresiona ENTER para regresar al menú...'
                    
                    clear
                    unset Port
                    ;;
                4)
                    clear
                    echo ' Listado de Puertos Habilitados:'
                    sudo ufw status

                    read -p "Ingrese el rango de puertos UDP que desea habilitar (inicial:final): " Port

                    sudo ufw allow $Port/udp

                    echo -e '\nLos puertos ' "$Port" han sido habilitados.
                    sudo ufw status | grep "$Port"

                    echo -e '\nPresiona ENTER para regresar al menú...'
                    
                    clear
                    unset Port
                    ;;
                *)
                    clear
                    echo -e '\e[31mLa opción que ingresaste es incorrecta.\e[m'
                    ;;
                esac

                echo '¿Qué quieres hacer?'
                echo '1) Agregar un puerto TCP.'
                echo '2) Agregar un puerto UDP.'
                echo '3) Habilitar un rango de puertos TCP.'
                echo '4) Habilitar un rango de puertos UCP.'
                echo '0) Regresar al menú principal.'

                echo -e '\n'
                read -p 'Ingrese el número de la opción deseada: ' option1
            done

            clear
            unset option1

            ;;
        6)
            clear
            echo 'Verificando instalación de resolvconf...'
            if [ -z "$(sudo systemctl is-enabled resolvconf | grep "enabled")" ]; then
                echo -e 'Instalando e iniciando el servicio resolvconf...\n'
                sudo apt update && sudo apt install resolvconf -y
                sudo service resolvconf start
                echo -e 'El estado del servicio resolvconf es:\n'
                sudo service resolvconf status
            else
                echo -e 'El servicio resolvconf ya está instalado. Iniciando...\n'
                if [ -z "$(echo $(sudo service resolvconf status) | grep "inactive")" ]; then
                    echo -e 'El servicio resolvconf está activo.'
                else
                    echo -e 'iniciando el servicio resolvconf...'
                    sudo service resolvconf start
                fi
                echo -e 'El estado del servicio resolvconf es:\n'
                echo $(sudo service resolvconf status)
            fi

            clear
            echo '¿Qué quieres hacer?'
            echo '1) Ver la tabla de DNS.'
            echo '2) Adicionar un nuevo nameserver a la tabla.'
            echo '3) Eliminar un nameserver de la tabla.'
            echo '0) Regresar al menú principal.'

            echo -e '\n'
            read -p 'Ingrese el número de la opción deseada: ' option1

            while [ $option1 -ne 0 ] || [ $option1 != '0' ]; do
                case $option1 in
                0)
                    ;;
                1)
                    clear
                    cat /etc/resolv.conf
                    echo -e '\nPresiona ENTER para regresar al menú...'
                    read -p ''
                    clear
                    ;;
                2)
                    clear
                    read -p 'Ingresa la IP del nuevo nameserver:  ' Ip
                    if [ -n "$(cat /etc/resolv.conf | grep "$Ip")" ]; then
                        echo 'La IP ingresada ya está registrada en la tabla de DNS.'
                    else
                        sudo sed -i "$(echo '$a nameserver' $Ip)" /etc/resolv.conf
                        echo -e '\nSe ha agregado el nameserver: \e[0;32m' "$Ip" '\e[m'
                    fi

                    echo -e '\nPresiona ENTER para regresar al menú...'
                    read -p ''
                    clear
                    unset Ip
                    ;;
                3)
                    clear
                    read -p 'Ingresa la IP del nameserver a eliminar:  ' IpServer
                    if [ -n "$(cat /etc/resolv.conf | grep "$IpServer")" ]; then
                        sudo sed -i "/$IpServer/d" /etc/resolv.conf
                        echo -e '\nSe ha eliminado la IP del nameserver: \e[0;32m' "$IpServer" '\e[m'
                    else
                        echo 'La IP del nameserver no está registrada en la tabla de DNS.'
                    fi

                    echo -e '\nPresiona ENTER para regresar al menú...'
                    read -p ''
                    clear
                    unset IpServer
                    ;;
                *)
                    clear
                    echo -e '\e[31mLa opción que ingresaste es incorrecta.\e[m'
                    ;;
                esac

                echo '¿Qué quieres hacer?'
                echo '1) Ver la tabla de DNS.'
                echo '2) Adicionar un nuevo nameserver a la tabla.'
                echo '3) Eliminar un nameserver de la tabla.'
                echo '0) Regresar al menú principal.'

                echo -e '\n'
                read -p 'Ingrese el número de la opción deseada: ' option1
            done

            clear
            unset option1
            ;;
        7)
            clear
            echo 'Para no afectar la conexión con el servidor, es importante que edites el siguiente archivo bajo la siguiente estructura, pero debes asegurarte que los datos sean correctos y el proxy este activo:'
            echo -e '\n'
            echo '###################################################'
            echo 'PROXY_ENABLED="yes"'
            echo 'HTTP_PROXY="10.236.50.83:8080"'
            echo 'HTTPS_PROXY="10.236.50.83:8080"'
            echo 'FTP_PROXY="10.236.50.83:8080"'
            echo 'NO_PROXY="localhost, 127.0.0.1, "'
            echo '###################################################'
            echo -e '\n'
            sudo nano /etc/sysconfig/proxy
            clear
            echo 'Aplicando los cambios ingresados...'
            sudo sudo netplan apply
            echo -e '\n\n'
            echo 'El proxy ha quedado configurado.'
            echo -e '\nPresiona ENTER para regresar al menú...'
            read -p ''
            clear
            ;;
        8)
            clear
            echo -e 'Proceso de instalacion de Docker CE...\n'
            read -p '¿Desea Instalar Docker? (y/n): ' answer

            if [[ $answer =~ ^[Yy]$ ]]
                then
                    ###############################################################
                    ## Instalación de Docker
                    cd ~/
                    echo -e '\nRealizando la instalación de los prerrequisitios y las configuraciones necesarias...\n'
                    sudo apt-get update
                    sudo apt install apt-transport-https ca-certificates curl software-properties-common -y
                    # curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
                    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor | sudo tee /usr/share/keyrings/docker-ce-archive-keyring.gpg > /dev/null
                    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-ce-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker-ce.list > /dev/null
                    sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable" -y
                    echo -e '\nRealizando instalación de Docker...\n'
                    sudo apt update
                    apt-cache policy docker-ce
                    sudo apt install docker-ce -y

                    echo -e '\nPresiona ENTER para continuar...'
                    read -p ''

                    clear
                    echo 'Proceso de instalación completado.'
                    echo -e '\nVerificando la versión de Docker instalada ...\n'
                    docker --version
                    
                    echo -e '\nPresiona ENTER para continuar...'
                    read -p ''
                    
                    clear
                    echo -e '\nCreando y configurando el usuario Docker...\n'

                    sudo adduser docker
                    user=docker
                    sudo usermod -a -G docker $user
                    grep $user /etc/group

                    echo -e '\nConfigurando el usuario actual en el grupo Docker...\n'

                    user=$(whoami)
                    sudo usermod -a -G docker $user
                    grep $user /etc/group

                    echo -e '\nVerificando creación del folder docker y ortorgando permisos...\n'
                    folder=/home/
                    sudo mkdir -p $folder/$user
                    sudo mkdir -p $folder/$user/Data
                    sudo chown -R $user:$user $folder/$user
                    sudo chown -R $user:$user $folder/$user/Data
                    ls -ltr $folder/

                    echo 'Usuario Docker listo.'
                    echo -e '\nPresiona ENTER para continuar...'
                    read -p ''

                    clear
                    echo -e 'Iniciando docker en el sistema...\n'
                    sudo systemctl enable docker
                    sudo systemctl start docker

                    echo -e '\nServicio Docker disponible...'
                    echo -e '\nPresiona ENTER para continuar...'
                    read -p ''

                    clear
                    echo -e 'Proceso de instalacion de Docker Compose...\n'
                    read -p '\n¿Desea Instalar Docker Componese? (y/n): ' answer

                    if [[ $answer =~ ^[Yy]$ ]]
                        then
                        ###############################################################
                        ## Instalación de Docker Compose

                        echo -e '\nIniciando la instalacion de Docker Compose...\n'

                        sudo mkdir -p /usr/local/bin
                        sudo curl -L "https://github.com/docker/compose/releases/download/1.26.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

                        sudo chmod +x /usr/local/bin/docker-compose

                        clear
                        echo -e '\nVerificando la versión de docker-compose...\n'
                        sudo docker-compose --version

                        echo -e '\nDocker Compose está instalado.\n'

                        echo -e '\nPresiona ENTER para continuar...'
                        read -p ''
                    fi
            fi

            echo -e '\nPresiona ENTER para regresar al menú...'
            read -p ''

            unset answer
            unset user
            unset folder
            clear
            ;;
        *)
            clear
            echo -e '\e[31mLa opción que ingresaste es incorrecta.\e[m'
            echo -e 'Por favor vuelve a intertarlo o ingresa "0" para salir.\n'
            ;;
    esac

    # Opciones del menú
    echo 'Aquí puedes realizar las siguientes acciones de administración: '
    echo '1) Cambiar el nombre del servidor.'
    echo '2) Cambiar partición de discos.'
    echo '3) Cambiar IP del servidor'
    echo '4) Cambiar tabla del Host'
    echo '5) Agregar permisos de Firewall.'
    echo '6) Editar DNS Server.'
    echo '7) Configurar proxy.'
    echo '8) Instalar Docker.'
    echo '0) Salir.'

    echo -e '\n'
    read -p 'Ingrese la opción: ' option

    # Limpiar terminal
    clear

done

unset option

clear