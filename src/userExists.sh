#!/bin/bash

function existsUser()
{
	local username="$1"
	if [ -z $username ]; then
		return 0
	fi

	##Buscar en el archivo de usuarios del sistema
	local file="/etc/passwd"
	while IFS= read -r line
	do
		local u=$(echo $line | cut -d ":" -f 1)
		local id=$(echo $line | cut -d ":" -f 3)
		if [ $id -gt 999 ] && [ $id -lt 10000 ] ; then
			if [ $u = $username ]; then
				return 1
			fi
		fi
	done <"$file"
	return 0
}

##Usuario a buscar
findUser="$1"

##Checa si existe el usuario
existsUser "$findUser"

##Si existe el usuario, entonces mandar mensaje
if [ $? -eq 1 ]; then

	##Conseguir el home del usuario
	userHome=$(getent passwd ${findUser} | cut -d: -f6)

	##Imprimir mensaje
	echo -e "El usuario existe!\n$userHome"

	##Salir sin ningun error
	exit 0
else
	echo "Usuario $findUser no existe en el sistema"

	##Salir con error, usuario no existe
	exit 2
fi


