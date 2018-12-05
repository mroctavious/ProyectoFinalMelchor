
pidFile="/var/run/VVIBot.pid"

case "$1" in
start)
	"${VVI_APP_FOLDER}/VVI.bin" &
	echo $! > $pidFile
	sleep 1
	"${VVI_APP_FOLDER}/newVideosFound.sh" &
	echo $! >> $pidFile
	;;
stop)
	cat $pidFile | xargs kill
	rm $pidFile
	;;
restart)
	cat $pidFile | xargs kill
	rm $pidFile
	sleep 1
	"${VVI_APP_FOLDER}/VVI.bin" &
	echo $! > $pidFile
	sleep 1
	"${VVI_APP_FOLDER}/newVideosFound.sh" &
	echo $! >> $pidFile
	;;
status)
	if [ -e $pidFile ]; then
		echo Video Vigilancia Inteligente is running..., pid=`cat $pidFile`
	else
		echo Video Vigilancia Inteligente is NOT running
		exit 1
	fi
	;;
*)
   echo "Usage: $0 {start|restart|stop|status}"
esac

exit 0
