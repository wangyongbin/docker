CURR_PATH=$(pwd|sed 's#/bin$##g');

#echo $CURR_PATH;

APPS_BASE=$CURR_PATH/application;
#echo $APPS_BASE;

source $CURR_PATH/bin/registry.conf;

APP_NAME='';
IMAGE_NAME='';
PORT='';
CMD='';

#cmd container start|stop|rm|logs|sh app_name [options]
#options
#-i image name.For example:tomcat-basic:1.0.
#-p publish port.For example:8080.
#


option='';

if [ -z $1 ];then
echo 'Argument 1 is required.';
exit 1;
fi


if [ $1 = '--help' ];then
	echo 'Commond for example:./container.sh <start|stop|rm|logs|sh> <AppName> <-i ImageName> [-p PORT].';
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
	APP_NAME=$arg;
elif [ $arg = '-i' ]; then
	option=$arg;
elif [ $arg = '-p' ]; then
	option=$arg;
elif [ ! -z $option ]; then
	#echo $option;
	if [ $option = '-i' ]; then
		IMAGE_NAME=$arg;
	elif [ $option = '-p' ]; then
		PORT=$arg;
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
#echo $APP_NAME;
#echo $IMAGE_NAME;
#echo $PORT;

APP_PATH=$APPS_BASE'/'$APP_NAME;

CMD_FULL='';

#自定义Host映射
OPTION_CUSTOM_HOSTS='';
if [ -f $APP_PATH/conf/hosts ];then
while read LINE
do
	if [[ ! $LINE =~ ^#|^$ ]];then
		OPTION_CUSTOM_HOSTS+=' --add-host '$LINE' ';
	fi
done < $APP_PATH/conf/hosts
fi


#全局Host映射
OPTION_GLOABLE_HOSTS='';
if [ -f $CURR_PATH/conf/globale-hosts ];then
while read LINE
do
	if [[ ! $LINE =~ ^#|^$ ]];then
		OPTION_GLOABLE_HOSTS+=' --add-host '$LINE' ';
	fi
done < $CURR_PATH/conf/globale-hosts
fi

#自定义数据卷
OPTION_CUSTOM_VOLUME='';
if [ -f $APP_PATH/conf/volume ];then
while read LINE
do
	if [[ ! $LINE =~ ^#|^$ ]];then
		OPTION_CUSTOM_VOLUME+=' -v '$APP_PATH/$LINE' ';
	fi
done < $APP_PATH/conf/volume
fi

#默认全局数据卷
OPTION_GLOBALE_VOLUME=' -v '$APP_PATH':/app_vol';
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


if [ $CMD = 'start' ]; then
	OPTION_PORT='';
	if [ ! -z $PORT ]; then
		OPTION_PORT='-p '$PORT;
	fi
	
	CMD_FULL='docker run -d '$OPTION_PORT' --name '$APP_NAME$OPTION_CUSTOM_HOSTS$OPTION_GLOABLE_HOSTS$OPTION_CUSTOM_VOLUME$OPTION_GLOBALE_VOLUME$OPTION_CUSTOM_ENV$OPTION_GLOBALE_ENV' '$IMAGE_REGISTRY$IMAGE_NAME;
	#echo $CMD_FULL;

elif [ $CMD = 'stop' ];then
	CMD_FULL='docker stop '$APP_NAME;

elif [ $CMD = 'rm' ];then
	CMD_FULL='docker rm '$APP_NAME;
elif [ $CMD = 'logs' ]; then
	CMD_FULL='docker logs -f '$APP_NAME;
elif [ $CMD = 'sh' ]; then
	CMD_FULL='docker exec -it '$APP_NAME' sh';	
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