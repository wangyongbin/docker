CURR_PATH=$(pwd)

#[option]service publish
SERVICE_PUBLISH=''

#[option]service network
SERVICE_NETWORK=()

#[option]service constraint
SERVICE_CONSTRAINT='node.role==manager'

#[option]service replicas
SERVICE_REPLICAS=1

source $CURR_PATH/conf/service.conf

if [ -z $SERVICE_NAME ];then
	echo "SERVICE_NAME is undefind in file: $CURR_PATH/conf/service.conf"
	exit 1
fi

if [ -z $SERVICE_TYPE ];then
	echo "SERVICE_TYPE is undefind in file: $CURR_PATH/conf/service.conf"
	exit 1
fi

if [ -z $SERVICE_IMAGE ];then
	echo "SERVICE_IMAGE is undefind in file: $CURR_PATH/conf/service.conf"
	exit 1
fi

if [ -z $SERVICE_LOCAL_PATH ];then
	echo "SERVICE_LOCAL_PATH is undefind in file: $CURR_PATH/conf/service.conf"
	exit 1
fi

#[option]server ssh port
SERVER_PORT=22

#[option]remote base path
REMOTE_BASE_PATH='easy_docker/container'

#[option]remote service path
REMOTE_SERVICE_PATH=$REMOTE_BASE_PATH/application/$SERVICE_NAME

source $CURR_PATH/conf/server.conf

if [ -z $SERVER ];then
	echo "SERVER is undefind in file: $CURR_PATH/conf/server.conf"
	exit 1
fi

if [ -z $SERVER_USER ];then
	echo "SERVER_USER is undefind in file: $CURR_PATH/conf/server.conf"
	exit 1
fi


if [[ ! $1 =~ ^publish|upgrade|offline$ ]];then
	echo 'Command for example:./deploy.sh <publish|upgrade|offline>'
	exit 1
fi




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


CMD_SERVICE_SETUP="./$REMOTE_BASE_PATH/bin/setup.sh $SERVICE_NAME $SERVICE_TYPE"

CMD_SERVICE_CREATE="./$REMOTE_BASE_PATH/bin/app-service.sh create $SERVICE_NAME -i $SERVICE_IMAGE $OPTION_PUBLISH $OPTION_NETWORK $OPTION_CONSTRAINT -r $SERVICE_REPLICAS"

CMD_SERVICE_START="./$REMOTE_BASE_PATH/bin/app-service.sh start $SERVICE_NAME -r $SERVICE_REPLICAS"

CMD_SERVICE_STOP="./$REMOTE_BASE_PATH/bin/app-service.sh stop $SERVICE_NAME"

CMD_SERVICE_REMOVE="./$REMOTE_BASE_PATH/bin/app-service.sh rm $SERVICE_NAME"

CMD_SERVICE_CLEAR="rm -rf $REMOTE_SERVICE_PATH"




if [ $1 = 'publish' ];then
	ssh -p $SERVER_PORT $SERVER_USER@$SERVER "$CMD_SERVICE_SETUP"
	scp $SERVICE_LOCAL_PATH $SERVER_USER@$SERVER:~/$REMOTE_SERVICE_PATH/apps/
	ssh -p $SERVER_PORT $SERVER_USER@$SERVER "$CMD_SERVICE_CREATE"
	exit 0
elif [ $1 = 'upgrade' ];then
	ssh -p $SERVER_PORT $SERVER_USER@$SERVER "$CMD_SERVICE_STOP"
	ssh -p $SERVER_PORT $SERVER_USER@$SERVER "$CMD_SERVICE_REMOVE"
	scp $SERVICE_LOCAL_PATH $SERVER_USER@$SERVER:~/$REMOTE_SERVICE_PATH/apps/
	ssh -p $SERVER_PORT $SERVER_USER@$SERVER "$CMD_SERVICE_CREATE"
elif [ $1 = 'offline' ];then
	ssh -p $SERVER_PORT $SERVER_USER@$SERVER "$CMD_SERVICE_STOP"
	ssh -p $SERVER_PORT $SERVER_USER@$SERVER "$CMD_SERVICE_REMOVE"
	ssh -p $SERVER_PORT $SERVER_USER@$SERVER "$CMD_SERVICE_CLEAR"
fi
