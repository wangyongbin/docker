#当前位置
CURR_PATH=$(pwd|sed 's#/bin$##g');


#DB 容器路径
DB_PATH=$CURR_PATH/db;
#Application 容器路径
APPLICATION_PATH=$CURR_PATH/application;

#容器名称，从第1参数中获取，必需的.
CONTAINER_NAME='';
#容器模版 默认为 tomcat
CONTAINER_TEMPLATE='tomcat';

#参数检查
function arugmentCheck()
{
#第1参数不允许为空，否则输出错误并退出
if [ -z $1 ];then
echo 'Argument 1 is required.';
exit 1;
fi
}

#help 处理
function isHelp()
{
#如果第1参数为"--help"，则输出帮助
if [ $1 = '--help' ];then
	echo 'Commond for example:./setup.sh <container_name> <tomcat|nginx|java|mysql>.'
	exit 0;
fi
}

function initVolume()
{
#TODO
return;
}
function updateVolume()
{
#TODO
return;
}
function releaseVolume()
{
#TODO
return;
}


#构建容器数据卷股价
function buildContainerVolume()
{

	APPLICATION_MATH_REGX='^(tomcat|nginx|java)$';
	DB_MATCH_REGX='^(mysql)$';

	if [[ $CONTAINER_TEMPLATE =~ $APPLICATION_MATH_REGX ]];then 
		mkdir -p $APPLICATION_PATH/$CONTAINER_NAME/logs;
		mkdir -p $APPLICATION_PATH/$CONTAINER_NAME/apps;
		mkdir -p $APPLICATION_PATH/$CONTAINER_NAME/conf;
		#init volume
	elif [[ $CONTAINER_TEMPLATE =~ $DB_MATCH_REGX ]];then
		mkdir -p $DB_PATH/$CONTAINER_NAME/logs;
		mkdir -p $DB_PATH/$CONTAINER_NAME/storage;
		mkdir -p $DB_PATH/$CONTAINER_NAME/conf;
		#init volume
	else 
	echo 'Unkwon template of application at argument 2.(tomcat|nginx. default tomcat)';
	rm -rf $APP_DIR;
	fi
}


arugmentCheck $1;
isHelp $1;

CONTAINER_NAME=$1;

#第二参数如果不为空，则赋值到CONTAINER_TEMPLATE
if [ ! -z $2 ];then
CONTAINER_TEMPLATE=$2;
fi

buildContainerVolume;








