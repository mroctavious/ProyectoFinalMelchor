##Funcion que maneja los errores, se pueden ir agregando mas
##Solo hay que agregar 
#	elif [ $numError -eq n ]; then 
#		echo "Descripcion de error"
#		exit 2
function error()
{
	##Numero del error
	local numError="$1"

	##Mensaje personalizado
	local mensaje="$2"

	if [ $numError -eq 1 ]; then
		echo "Error de sintaxis!"
		echo "Mensaje: $mensaje"
		echo "Opciones:"
		echo -e "\t-n,--server-name\tName of the server"
		echo -e "\t-p,--install-path\tInstall Path"
		echo -e "\t-t,--bot-token\tTelegram Bot Token"
		exit 1
	elif [ $numError -eq 2 ]; then
		echo "Error al crear path, existe $mensaje"
		exit 2
	else
		echo "Error: $mensaje"
		exit 99
	fi

}


