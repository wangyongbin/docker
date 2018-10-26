#!/bin/sh

SERVICE_ACTION=$1

SERVICE_NAME=$2

BASE_PATH=~/easy_docker/container

BASE_CONF_PATH=~/docker_deploy/conf/unmanaged/$SERVICE_NAME

APPS_PATH=$BASE_PATH/application;

#[option]service publish
SERVICE_PUBLISH=''

#[option]service network
SERVICE_NETWORK=()

#[option]service constraint
SERVICE_CONSTRAINT='node.role==manager'

#[option]service replicas
SERVICE_REPLICAS=1

if [ ! -f $BASE_CONF_PATH/service.conf ];then

	echo "$BASE_CONF_PATH/service.conf not found.";
	exit 1;
fi

echo $BASE_CONF_PATH
source $BASE_CONF_PATH/service.conf

# 参数验证
if [ -z $SERVICE_NAME ];then
	echo "SERVICE_NAME is undefind in file: $BASE_CONF_PATH/service.conf"
	exit 1; #参数异常
fi

if [ -z $SERVICE_TYPE ];then
	echo "SERVICE_TYPE is undefind in file: $BASE_CONF_PATH/service.conf"
	exit 1
fi

if [ -z $SERVICE_IMAGE ];then
	echo "SERVICE_IMAGE is undefind in file: $BASE_CONF_PATH/service.conf"
	exit 1
fi

if [ -z $SERVICE_LOCAL_PATH ];then
	echo "SERVICE_LOCAL_PATH is undefind in file: $BASE_CONF_PATH/service.conf"
	exit 1
fi

# 多个
OPTION_PUBLISH=''
if [ ! -z $SERVICE_PUBLISH ];then
	OPTION_PUBLISH='-p '$SERVICE_PUBLISH
fi

OPTION_NETWORK=''
if [ ! 0 = ${#SERVICE_NETWORK[@]} ];then
	for n in ${SERVICE_NETWORK[@]};
	do OPTION_NETWORK+=" -n "$n;
	done
fi

OPTION_CONSTRAINT=''

if [ ! -z $SERVICE_CONSTRAINT ];then
	OPTION_CONSTRAINT=' -c '$SERVICE_CONSTRAINT
fi


# 执行命令
CMD_SERVICE_SETUP="sh $BASE_PATH/bin/setup.sh $SERVICE_NAME $SERVICE_TYPE"

CMD_SERVICE_COPY="cp $SERVICE_LOCAL_PATH $APPS_PATH/$SERVICE_NAME/apps"

CMD_SERVICE_CREATE="sh $BASE_PATH/bin/app-service.sh create $SERVICE_NAME -i $SERVICE_IMAGE $OPTION_PUBLISH $OPTION_NETWORK $OPTION_CONSTRAINT -r $SERVICE_REPLICAS"

CMD_SERVICE_START="sh $BASE_PATH/bin/app-service.sh start $SERVICE_NAME -r $SERVICE_REPLICAS"

CMD_SERVICE_STOP="sh $BASE_PATH/bin/app-service.sh stop $SERVICE_NAME"

CMD_SERVICE_REMOVE="sh $BASE_PATH/bin/app-service.sh rm $SERVICE_NAME"

CMD_SERVICE_CLEAR="rm -rf $APPS_PATH/$SERVICE_NAME"

CMD_SERVICE_CONFIG_CLEAR="rm -rf $BASE_CONF_PATH"

if [ $SERVICE_ACTION = 'deploy' ];then

	SWARM_SERVICE_NAME=$(docker service ls | grep $SERVICE_NAME | awk '{print $2}');

 	if [ -z $SWARM_SERVICE_NAME ];then
		$CMD_SERVICE_SETUP;
		$CMD_SERVICE_COPY;
	        $CMD_SERVICE_CREATE;
	else
		$CMD_SERVICE_STOP;
	        $CMD_SERVICE_COPY;
        	$CMD_SERVICE_START;
	fi

elif [ $SERVICE_ACTION = 'offline' ];then

	$CMD_SERVICE_STOP;
   	$CMD_SERVICE_REMOVE;
   	$CMD_SERVICE_CLEAR;
	$CMD_SERVICE_CLEAR;

fi