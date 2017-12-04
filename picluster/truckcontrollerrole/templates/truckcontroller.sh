#!/bin/sh
cd /home/pi/truckcontrollerdemo
export KSIM_ACCOUNT_NAME=Red-Hat
export KSIM_NUM_GATEWAYS=1
export KSIM_BASE_NAME={{ksim_base_name}}
export KSIM_NAME_FACTORY=
#KSIM_BROKER_URL=tcp://mbpTimDeBorger.local:1883
export KSIM_BROKER_USER=demo-gw2
export KSIM_BROKER_PASSWORD=RedHat123
export KSIM_BROKER_HOST={{ksim_broker_host}}
export KSIM_BROKER_PORT={{ksim_broker_port}}
#
BASE=/home/pi/truckcontrollerdemo
PID=$BASE/app.pid
LOG=$BASE/app.log
ERROR=$BASE/app-error.log

#PORT=11211
#LISTEN_IP='0.0.0.0'
#MEM_SIZE=4
CMD='java -cp .:./TruckManager-1.0.0-SNAPSHOT-jar-with-dependencies.jar com.rh.rbpi.iot.messaging.TruckControlSystem'
COMMAND="$CMD"

USR=pi

status() {
    echo
    echo "==== Status"

    if [ -f $PID ]
    then
        echo
        echo "Pid file: $( cat $PID ) [$PID]"
        echo
        ps -ef | grep -v grep | grep $( cat $PID )
    else
        echo
        echo "No Pid file"
    fi
}

start() {
    if [ -f $PID ]
    then
        echo
        echo "Already started. PID: [$( cat $PID )]"
    else
        echo "==== Start"
        touch $PID
        if nohup $COMMAND >>$LOG 2>&1 &
        then echo $! >$PID
             echo "Done."
             echo "$(date '+%Y-%m-%d %X'): START" >>$LOG
        else echo "Error... "
             /bin/rm $PID
        fi
    fi
}

kill_cmd() {
    SIGNAL=""; MSG="Killing "
    while true
    do
        LIST=`ps -ef | grep -v grep | grep $CMD | grep -w $USR | awk '{print $2}'`
        if [ "$LIST" ]
        then
            echo; echo "$MSG $LIST" ; echo
            echo $LIST | xargs kill $SIGNAL
            sleep 2
            SIGNAL="-9" ; MSG="Killing $SIGNAL"
            if [ -f $PID ]
            then
                /bin/rm $PID
            fi
        else
           echo; echo "All killed..." ; echo
           break
        fi
    done
}

stop() {
    echo "==== Stop"

    if [ -f $PID ]
    then
        if kill $( cat $PID )
        then echo "Done."
             echo "$(date '+%Y-%m-%d %X'): STOP" >>$LOG
        fi
        /bin/rm $PID
#        kill_cmd
    else
        echo "No pid file. Already stopped?"
    fi
}

case "$1" in
    'start')
            start
            ;;
    'stop')
            stop
            ;;
    'restart')
            stop ; echo "Sleeping..."; sleep 1 ;
            start
            ;;
    'status')
            status
            ;;
    *)
            echo
            echo "Usage: $0 { start | stop | restart | status }"
            echo
            exit 1
            ;;
esac

exit 0

