CURR_PATH=$(pwd);
#echo $CURR_PATH;
APPS_BASE=$CURR_PATH/applications;
#echo $APPS_BASE;

IMAGE_REGISTRY='registry.ib2000.net:50001/';
# IMAGE_REGISTRY='localhost:5000/';

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

CMD_FULL='';

OPTION_HOSTS='';

while read LINE
do
	if [[ ! $LINE =~ ^#|^$ ]];then
		OPTION_HOSTS+=' --add-host '$LINE' ';
	fi
done < $CURR_PATH/conf/hosts



if [ $CMD = 'start' ]; then
	OPTION_PORT='';
	if [ ! -z $PORT ]; then
		OPTION_PORT='-p '$PORT':80 ';
	fi
	APP_PATH=$APPS_BASE'/'$APP_NAME;
	CMD_FULL='docker run -d '$OPTION_PORT'-v '$APP_PATH':/app_vol --name '$APP_NAME$OPTION_HOSTS' '$IMAGE_REGISTRY$IMAGE_NAME;
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