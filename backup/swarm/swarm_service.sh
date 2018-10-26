#!/bin/bash
#PARTTEN="";

DOCKER_SERVICE_LS='docker service ls';
SERVICE_FILTER='';
GREP_FILTER='|grep -v grep';
SERVICE_START_CMD='"docker service scale "$2"=1"';
SERVICE_STOP_CMD='"docker service scale "$2"=0"';
SERVICE_RM_CMD='"docker service rm "$2';
#$1 start|stop|rm
if [ -z "$1" ];then
echo 'Argument 1 is required.start|stop|rm.';
exit;
elif [ 'start' = $1 ];then
AWK_CMD="|awk '{print $SERVICE_START_CMD}'";
elif [ 'stop' = $1 ];then
AWK_CMD="|awk '{print $SERVICE_STOP_CMD}'";
elif [ 'rm' = $1 ];then
AWK_CMD="|awk '{print $SERVICE_RM_CMD}'";
else
echo 'Unkwon argument at position 1.Actually is '$1',Pelease use start|stop|rm.';
exit;
fi


if [ $# > 1 ];then
SERVICE_FILTER='|grep '$2' '$3;
fi

CMD=$DOCKER_SERVICE_LS$SERVICE_FILTER$GREP_FILTER;
echo 'Services will be '$1':';
eval $CMD;
read -p 'Are you sure?(y or n):' SELECT_OPTION;

if [ $SELECT_OPTION = 'y' ];then
CMD+=$AWK_CMD'|sh';
eval $CMD;
fi
exit;