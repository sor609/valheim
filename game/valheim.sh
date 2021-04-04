#!/bin/bash

# LINUX START SCRIPT

# Server settings
HOMEDIR=/home/valheim/game
NAME="<your server name>"
PORT=8443
PWDZ="<some password here>"
PUBLIC="yes"


#### no modifications required below ####

# add libraries required for the game
export LD_LIBRARY_PATH=$HOMEDIR/linux64:$LD_LIBRARY_PATH

check_running () {
	# returns 0 if server is running, 1 if not
	if [ -f $HOMEDIR/.pid ]; then
		VAL_PID=`cat $HOMEDIR/.pid`
		/usr/bin/ps --no-headers -q $VAL_PID >>/dev/null
		if [ $? = 0 ]; then
			return 0
		else
			rm $HOMEDIR/.pid
			return 1
		fi
	else
		return 1
	fi
}

start_server () {
	if check_running; then
		VAL_PID=`cat $HOMEDIR/.pid`
		echo "`date '+%Y-%m-%d %H:%M:%S'` UTC - [$VAL_PID]Server already running!" 
		exit 1
	else
		# setup Valheim Steam App Id
		export SteamAppId=892970

		# install/update Valheim server
		/usr/games/steamcmd +login anonymous +force_install_dir $HOMEDIR +app_update 896660 +quit

		if [ $? != 0 ]; then
			echo "Error occurred during install/update"
			exit 1
		fi

		# finally run server
		if [ $PUBLIC = "no" ]; then PUBZ=0
		elif [ $PUBLIC = "yes" ]; then PUBZ=1
		else
			echo "Public mode not set correctly, will run non-public"
			PUBZ=0
		fi

		$HOMEDIR/valheim_server.x86_64 -name $NAME -port $PORT -world "Dedicated" -password $PWDZ -public $PUBZ > /dev/null &

		VAL_PID=$!
		echo "`date '+%Y-%m-%d %H:%M:%S'` UTC - [$VAL_PID]Server started on port $PORT"
		echo $VAL_PID > $HOMEDIR/.pid
	fi
}

stop_server () {
	if check_running; then
		VAL_PID=`cat $HOMEDIR/.pid`
		# SIGINT saves worlds file before stopping server
		kill -s SIGINT $VAL_PID
		sleep 10
	else
		echo "`date '+%Y-%m-%d %H:%M:%S'` UTC - Server already stopped" 
		exit 1
	fi
	if ! check_running; then
		echo "`date '+%Y-%m-%d %H:%M:%S'` UTC - [$VAL_PID]Server stopped" 
	else
		echo "Error stopping server, investigate!"
		exit 1
	fi
}

restart_server () {
	stop_server
	start_server
}


### MAIN ###

case $1 in
	start)
		start_server
		;;
	stop)
		stop_server
		;;
	restart)
		restart_server
		;;
	status)
		if check_running; then
			VAL_PID=`cat $HOMEDIR/.pid`
			echo "Server running with PID $VAL_PID"
		else
			echo "Server stopped"
		fi
		;;
	*)
		echo "Invalid argument! Usage: start|stop|status"
		exit 1
		;;
esac

#end
