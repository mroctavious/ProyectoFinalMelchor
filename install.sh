#!/bin/bash

##Ejemplo de instalacion ./install.sh -p /opt/ -n pko -t "523301333:AAFoDVQcngPxRadhlLcN3JkWxyzP8wIrrDc"

##Instalador de la paqueteria Xipetotec
##Verificar si es usuario root, solo root  puede correr este programa
if [ "$EUID" -ne 0 ]
        then echo "Solo root puede instalar este programa"
        exit
fi

function createVVIService
{
	local out="$1"
	local VVIPath="$2"
	echo "[Unit]" > $out
	echo "Description=Programa que detecta movimiento, graba y notifica a los administradores del sistema." >> $out
	echo "" >> $out
	echo "#The service will wait for  networking and syslog" >> $out
	echo "After=syslog.target network.target" >> $out
	echo -e "\n\n[Service]" >> $out
	echo "Type=forking" >> $out
	echo "" >> $out
	echo "##PID File location, servira para terminar procesos" >> $out
	echo "PIDFile=/var/run/VVIBot.pid" >> $out
	echo "" >> $out
	echo "##Indicar que ejecutar cuando se ejecute el argumento start" >> $out
	echo "ExecStart=${VVIPath}/VVIServiceManager.sh start" >> $out
	echo "" >> $out
	echo "##Proceso de reinicio de proceso" >> $out
	echo "ExecRestart=${VVIPath}/VVIServiceManager.sh restart" >> $out
	echo "" >> $out
	echo "##Imprimir status del servicio" >> $out
	echo "ExecStatus=${VVIPath}/VVIServiceManager.sh status" >> $out
	echo "" >> $out
	echo "##Script que se ejecutara al parar el servicio" >> $out
	echo "ExecStop=${VVIPath}/VVIServiceManager.sh stop" >> $out
	echo "" >> $out
	echo "#Automatic restart" >> $out
	echo "Restart=on-failure" >> $out
	echo "" >> $out
	echo "#Time for system to wait before restart" >> $out
	echo "Restartsec=12s" >> $out
	echo -e "\n\n[Install]" >> $out
	echo "WantedBy=multi-user.target" >> $out

}
function createBashProgram
{
	local program="$1"
	local configSRC="$2"
	local srcProgram="$3"

	echo "#!/bin/bash" > $program

	echo "############################################" >> $program
	echo "####    Made by Octavio Rodriguez       ####" >> $program
	echo "####  UNIVERSIDAD AUTONOMA DE QUERETARO ####" >> $program
	echo "############################################" >> $program


	echo "##Verificar si es usuario root, solo root  puede correr este programa" >> $program
	echo 'if [ "$EUID" -ne 0 ]' >> $program
	echo "        then echo 'Solo root puede ejecutar este programa'" >> $program
	echo "        exit" >> $program
	echo "fi" >> $program

	echo "##Incluir librerias" >> $program
	echo "source $configSRC" >> $program
	echo " " >> $program
	cat $srcProgram >> $program
}


##Funcion que crea archivo de configuracion que puede ser importado
#por cualquier script para asi saber que configuracion usar
function createConfigFile
{
	local path="$1"
	local token="$2"
	local out="$path/config"
	echo "SERVER_NAME=${serverName}" > $out
	echo "XIPE_CONFIG_PATH=${configPath}" >> $out
	echo "XIPE_APP_PATH=$installFullPath" >> $out
	echo "VVI_CONFIG_FOLDER=${VVI_Config}" >> $out
	echo "HIKURILED_CONFIG_FOLDER=${HikuriLED_Config}" >> $out
	echo "ALLOWED_BOT_USERS_FOLDER=${allowedUsers_Config}" >> $out
	echo "VVI_APP_FOLDER=${VVI_Path}" >> $out
	echo "HIKURILED_APP_FOLDER=${HikuriLED_Path}" >> $out
	echo "FINDUSER_APP_FOLDER=${findUser_Path}" >> $out
	echo "PYTHON_VIDEO_SCRIPT=${VVI_Path}/bot_cam.py" >> $out
	echo "NEW_VIDEO_CREATED=${VVI_Config}/new" >> $out
	echo "OLD_VIDEOS_FOLDER=${VVI_Config}/old" >> $out
	echo "BOT_TOKEN='${token}'" >> $out

}

#Instalacion de Video Vigilancia Inteligente
function installVVI
{
	##Ubicaciones de instalacion
	local configPath="$1"
	local appPath="$2"
	local serviceFileLoc="/etc/systemd/system/VVI2.service"

	##Agregar header al programa de bash
	createBashProgram "${appPath}/AdminNotifications.sh" "${configPath}" "${SRC_FOLDER}/AdminNotifications.sh"
	createBashProgram "${appPath}/newVideosFound.sh" "${configPath}" "${SRC_FOLDER}/newVideosFound.sh"
	createBashProgram "${appPath}/VVIServiceManager.sh" "${configPath}" "${SRC_FOLDER}/VVIServiceManager.sh"

	##Copiar binarios y scripts de python que vamos a ejecutar
	cp "${SRC_FOLDER}/bot_cam.py" "${appPath}/"
	cp "${SRC_FOLDER}/VVI.bin" "${appPath}/"

	##Creamos archivo para generar servicio
	createVVIService "$serviceFileLoc" "$appPath"

	##Cambiamos a los permisos necesarios
	chmod 664 "$serviceFileLoc"
	chmod 755 "${appPath}/AdminNotifications.sh"
	chmod 755 "${appPath}/newVideosFound.sh"
	chmod 755 "${appPath}/VVIServiceManager.sh"

	##Recargamos servicios de la carpeta
	systemctl daemon-reload

	##Iniciar el servicio
	systemctl start VVI2.service
}

function createUninstaller
{
	local out="$1"
	local mainFolder="$2"
	local configFolder="$3"
	echo "#!/bin/bash" > $out
	echo 'unlink "/usr/local/bin/userExists"' >> $out
	echo "systemctl stop VVI2" >> $out
	echo "rm -rf $mainFolder $configFolder" >> $out
	echo 'systemctl disable VVI2'  >> $out
	echo 'rm /etc/systemd/system/VVI2.service' >> $out
	echo 'systemctl daemon-reload' >> $out
	echo 'echo Uninstall completed!' >> $out
	chmod 700 $out
}

##Instalar script que checa si existe un usuario nuevo
function installUserExists
{
	local appPath="$1"
	cp "${SRC_FOLDER}/userExists.sh" "${appPath}/userExists.sh"
	chmod 755 "${appPath}/userExists.sh"
	ln -s "${appPath}/userExists.sh" "/usr/local/bin/userExists"
}

##Directorio de ubicacion del folder de instalacion
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
SRC_FOLDER="${DIR}/src"

##Incluir librerias
source ${DIR}/include/errors.sh

##Recorrer y verificar entradas
numeroArgumentos=${#@}
i=0

##Declarar Arreglo
declare -A argumentos

##Agregar argumentos al arreglo
for j in $@; do
	cleaned=${j%/}
	argumentos[$i]=$cleaned
	i=$((i+1))
done

##Analizar la entrada
for k in $(seq 0 $((i-1)) );
do
	##Siguiente argumento es serverAdmin
	if [ ${argumentos[$k]} = "-n" ] || [ ${argumentos[$k]} = "--server-name" ]; then
		serverName=${argumentos[$((k+1))]}

	elif [ ${argumentos[$k]} = "-p" ] ||  [ ${argumentos[$k]} = "--install-path" ]; then
		installPath=${argumentos[$((k+1))]}

	elif [ ${argumentos[$k]} = "-t" ] ||  [ ${argumentos[$k]} = "--bot-token" ]; then
		botToken=${argumentos[$((k+1))]}
	fi
done


##Verificamos que se hayan ingresado TODOS los datos necesarios
if [ -z $installPath ]; then
	error 1 "Falto ingresar el path de instalacion"
fi

if [ -z $serverName ]; then
	error 1 "Falto ingresar el nombre del servidor"
fi

if [ -z $botToken ]; then
	echo "Falto ingresar el TOKEN del bot de Telegram"
	botToken="WRITE YOUR BOT TOKEN HERE"
fi

##Por si se agregan mas verificaciones, se creo esta variable que
#controla si se continua el flujo de la instalacion
everythingOK=1

if [ $everythingOK -eq 1 ]; then

	##Carpetas de configuracion
	configPath="/etc/${serverName}"
	VVI_Config="${configPath}/VVI"
	HikuriLED_Config="${configPath}/HikuriLED"
	allowedUsers_Config="${configPath}/allowedUsers"

	##Carpetas de programas
	installFullPath="${installPath}/${serverName}"
	VVI_Path="${installFullPath}/VVI"
	HikuriLED_Path="${installFullPath}/HikuriLED"
	findUser_Path="${installFullPath}/FindUser"

	##Crear carpetas root de la aplicacion
	mkdir ${configPath}  2> /dev/null
	if [ $? -ne 0 ]; then
		error 2 "${configPath}";
	fi
	mkdir ${installPath}  2> /dev/null

	##Crear carpetas de configuracion
	mkdir ${VVI_Config} ${HikuriLED_Config} ${allowedUsers_Config} ${installFullPath}

	##Creacion de las carpetas que contendran los programas
	mkdir ${VVI_Path} ${HikuriLED_Path} ${findUser_Path}

	##Folders donde se encontran los videos nuevos y viejos
	mkdir "${VVI_Config}/new" "${VVI_Config}/old"

	##Copiar los programas a la carpeta
	##Crear archivo universal
	createConfigFile "${configPath}" "${botToken}"

	##Instalar Video Vigilancia Inteligente
	installVVI "${configPath}/config" "${VVI_Path}"

	##Instalar script buscador
	installUserExists "${findUser_Path}"

	##Crear desinstalador
	createUninstaller "${installFullPath}/uninstall.sh" "${installFullPath}" "${configPath}"

	##Fin de la instalacion
fi



