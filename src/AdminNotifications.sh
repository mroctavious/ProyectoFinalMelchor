
##Funcion que manda mensaje al bot de telegram, especificando mensaje y a quien
function sendMessage
{
	local msg=$1;
	local id=$2;

	curl -s "https://api.telegram.org/bot${BOT_TOKEN}/sendMessage?chat_id=$id&text=$msg" 2>&1 > /dev/null
}

##Funcion que abre todos los archivos de la carpeta de configuracion y consigue sus IDs
#Para despues enviarles mensajes
function sendToAll
{
	local msg=$1;

	for q in $( ls $ALLOWED_BOT_USERS_FOLDER/* ); do
		user=$(basename $q);
		id=$(cat $q | tr -d '\040\011\012\015');
		sendMessage "$msg" "$id";
	done
}

sendToAll "$1"
