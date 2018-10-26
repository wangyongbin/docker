CURR_PATH=$(pwd|sed 's#/bin$##g');

#echo $CURR_PATH;
# APPS_BASE=$CURR_PATH/application;
APPS_BASE=$CURR_PATH/db;
#echo $APPS_BASE;

source $CURR_PATH/bin/registry.conf;

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
		OPTION_PORT=' --publish '$arg;
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

APP_PATH=$APPS_BASE'/'$SERVICE_NAME;


CMD_FULL=''


OPTION_HOSTS='';


#自定义Host映射
OPTION_CUSTOM_HOSTS='';
if [ -f $APP_PATH/conf/hosts ];then
while read LINE
do
	if [[ ! $LINE =~ ^#|^$ ]];then
		OPTION_CUSTOM_HOSTS+=' --host '$LINE' ';
	fi
done < $APP_PATH/conf/hosts
fi


#全局Host映射
OPTION_GLOABLE_HOSTS='';
if [ -f $CURR_PATH/conf/globale-hosts ];then
while read LINE
do
	if [[ ! $LINE =~ ^#|^$ ]];then
		OPTION_GLOABLE_HOSTS+=' --host '$LINE' ';
	fi
done < $CURR_PATH/conf/globale-hosts
fi


#自定义数据卷
OPTION_CUSTOM_VOLUME='';
if [ -f $APP_PATH/conf/volume ];then
while read LINE
do
	if [[ ! $LINE =~ ^#|^$ ]];then
		# OPTION_CUSTOM_VOLUME+=' -v '$APP_PATH/$LINE' ';

		_TMP=' --mount type=bind,source='$APP_PATH/$LINE' ';
		OPTION_CUSTOM_VOLUME+=$(echo $_TMP|sed 's#:#,destination=#g');

		echo $OPTION_CUSTOM_VOLUME;

		# ' --mount type=bind,source='$APP_PATH',destination=/app_vol'
	fi
done < $APP_PATH/conf/volume
fi

#默认全局数据卷
OPTION_GLOBALE_VOLUME=' --mount type=bind,source='$APP_PATH',destination=/app_vol ';
# if [ -f $APP_PATH/conf/env ];then
# while read LINE
# do
# 	if [[ ! $LINE =~ ^#|^$ ]];then
# 		OPTION_CUSTOM_ENV+=' -v '$APPS_BASE/$LINE' ';
# 	fi
# done < $CURR_PATH/conf/env
# fi


#自定义环境变量
OPTION_CUSTOM_ENV='';
if [ -f $APP_PATH/conf/env ];then
while read LINE
do
	if [[ ! $LINE =~ ^#|^$ ]];then
		OPTION_CUSTOM_ENV+=' -e '$LINE' ';
	fi
done < $APP_PATH/conf/env
fi

#全局环境变量
OPTION_GLOBALE_ENV='';
if [ -f $CURR_PATH/conf/globale-env ];then
while read LINE
do
	if [[ ! $LINE =~ ^#|^$ ]];then
		OPTION_GLOBALE_ENV+=' -e '$LINE' ';
	fi
done < $CURR_PATH/conf/globale-env
fi





if [ $CMD = 'create' ]; then
	
	CMD_FULL='docker service create  --name '$SERVICE_NAME$OPTION_CUSTOM_HOSTS$OPTION_GLOABLE_HOSTS$OPTION_CUSTOM_VOLUME$OPTION_GLOBALE_VOLUME$OPTION_CUSTOM_ENV$OPTION_GLOBALE_ENV$OPTION_NETWORK$OPTION_CONSTRAINT$OPTION_PORT$OPTION_REPLICAS' '$IMAGE_REGISTRY$IMAGE_NAME;
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

