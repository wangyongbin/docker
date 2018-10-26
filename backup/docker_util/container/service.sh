CURR_PATH=$(pwd);
#echo $CURR_PATH;
APPS_BASE=$CURR_PATH/applications;
#echo $APPS_BASE;

IMAGE_REGISTRY='registry.ib2000.net:50001/';
# IMAGE_REGISTRY='localhost:5000/';
SERVICE_NAME='';
#-i
IMAGE_NAME='';
#-n
NETWORK='';
#-p
PROT='';
#-c
CONSTRAINT='';
#-r
REPLICAS=1;
CMD='';



#cmd container start|stop|rm|logs|sh|reset SERVICE_NAME [options]
#options
#-i image name.For example:tomcat-basic:1.0.
#-p publish port.For example:8080.
#-c constraint.For example:node.role == manager.
#-n network.For example:vlan_coss.
#-r replicas.For example:


option='';

if [ -z $1 ];then
echo 'Argument 1 is required.';
exit 1;
fi

if [ $1 = '--help' ];then
	echo 'Commond for example:./service.sh <create|start|stop|resize|rm|logs> <Service> [-i ImageName,-p Port,-n Network,-c constraint,-r replicas].';
	exit 0;
fi

index=1;
for arg in $@ ; do
#echo $index;
#echo 'arg:'$arg;
#echo 'option:'$option;
if [ $index = 1 ]; then
	CMD=$arg;
elif [ $index = 2 ]; then
	SERVICE_NAME=$arg;
elif [ $arg = '-i' ]; then
	option=$arg;
elif [ $arg = '-n' ]; then
	option=$arg;
elif [ $arg = '-p' ]; then
	option=$arg;
elif [ $arg = '-c' ]; then
	option=$arg;
elif [ $arg = '-r' ]; then
	option=$arg;
elif [ ! -z $option ]; then
	#echo $option;
	if [ $option = '-i' ]; then
		IMAGE_NAME=$arg;
	elif [ $option = '-n' ]; then
		OPTION_NETWORK+=" --network "$arg;
	elif [ $option = '-p' ]; then
		OPTION_PORT=' --publish '$arg':80';
	elif [ $option = '-c' ]; then
		OPTION_CONSTRAINT=' --constraint "'$arg'"';
	elif [ $option = '-r' ]; then
		REPLICAS=$arg;
		OPTION_REPLICAS=' --replicas '$arg;
	else
		echo 'Syntax error option at ^"'$option'".';
		exit 1;
	fi
	option='';
else
	echo 'Syntax error option at ^"'$arg'".';
	exit 1;
fi

let index+=1;

done

if [ $index = 2 ]; then
	echo 'Syntax error option at ^"'$CMD'".';
	exit 1;
fi

if [ ! -z $option ]; then
	echo 'Syntax error option at ^"'$option'".';
	exit 1;
fi



#echo $CMD;
#echo $SERVICE_NAME;
#echo $IMAGE_NAME;
#echo $NETWORK;


CMD_FULL=''


OPTION_HOSTS='';

while read LINE
do
	if [[ ! $LINE =~ ^#|^$ ]];then
		OPTION_HOSTS+=' --host "'$LINE'" ';
	fi
done < $CURR_PATH/conf/hosts


if [ $CMD = 'create' ]; then
	# OPTION_NETWORK='';
	# if [ ! -z $NETWORK ]; then
	# 	OPTION_NETWORK=' --network '$NETWORK;
	# fi
	# OPTION_PORT='';
	# if [ ! -z $PORT ]; then
	# 	OPTION_PORT=' --publish '$PORT':80';
	# fi
	# OPTION_CONSTRAINT='';
	# if [ ! -z $CONSTRAINT ]; then
	# 	OPTION_CONSTRAINT=' --constraint "'$CONSTRAINT'"';
	# fi
	# OPTION_REPLICAS='';
	# if [ ! -z $REPLICAS ]; then
	# 	OPTION_REPLICAS=' --replicas '$REPLICAS;
	# fi


	APP_PATH=$APPS_BASE'/'$SERVICE_NAME;
	CMD_FULL='docker service create --mount type=bind,source='$APP_PATH',destination=/app_vol --name '$SERVICE_NAME$OPTION_HOSTS$OPTION_NETWORK$OPTION_CONSTRAINT$OPTION_PORT$OPTION_REPLICAS' '$IMAGE_REGISTRY$IMAGE_NAME;
	#echo $CMD_FULL;

elif [ $CMD = 'start' ];then
	CMD_FULL='docker service scale '$SERVICE_NAME'='$REPLICAS;

elif [ $CMD = 'stop' ];then
	CMD_FULL='docker service scale '$SERVICE_NAME'=0';

elif [ $CMD = 'resize' ];then
	CMD_FULL='docker service scale '$SERVICE_NAME'='$REPLICAS;

elif [ $CMD = 'rm' ];then
	CMD_FULL='docker service rm '$SERVICE_NAME;
elif [ $CMD = 'logs' ]; then
	CMD_FULL='docker service logs -f '$SERVICE_NAME;
# elif [ $CMD = 'sh' ]; then
# 	CMD_FULL='docker exec -it '$SERVICE_NAME' sh';
else
	echo 'Unkwon command for '$CMD;
	exit 1;
fi

echo $CMD_FULL;
eval $CMD_FULL;




#tomcat
#docker run -d -p 8080:80 -v /Users/lidonghai/Develop/docker/docker/volume/applications/helloworld_tomcat:/app_vol tomcat-basic:1.0

#nginx
#docker run -d -p 8080:80 -v /Users/lidonghai/Develop/docker/docker/volume/applications/nginx_example/:/app_vol registry.ib2000.net:50001/nginx-basic:1.0