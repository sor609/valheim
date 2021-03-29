#!/bin/bash

set -x

VALHEIMHOME=/home/valheim/game
INSTANCE="`uname -n`:9091"

if [ -f $VALHEIMHOME/.pid ]; then
	VAL_PID=`cat $VALHEIMHOME/.pid`
	/usr/bin/ps --no-headers -q $VAL_PID >/dev/null
	if [ $? = 0 ]; then
		cat << EOF | /usr/bin/curl --request POST --data-binary @- http://localhost:9091/metrics/job/pushgateway/instance/$INSTANCE
# TYPE pushgateway_valheim_server_up gauge
pushgateway_valheim_server_up 1
EOF
	else
		cat << EOF | /usr/bin/curl --request POST --data-binary @- http://localhost:9091/metrics/job/pushgateway/instance/$INSTANCE
# TYPE pushgateway_valheim_server_up gauge
pushgateway_valheim_server_up 0
EOF
	fi
else
	exit 1
fi
