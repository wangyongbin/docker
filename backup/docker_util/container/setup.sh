CURR_PATH=$(pwd);
APP_NAME='';
APP_TEMPLATE='tomcat';




if [ -z $1 ];then
echo 'Argument 1 is required.';
exit 1;
fi


if [ $1 = '--help' ];then
	echo 'Commond for example:./setup.sh <AppName> <tomcat|nginx|java>.'
	exit 0;
fi


APP_NAME=$1;
APP_DIR=$CURR_PATH'/applications/'$APP_NAME;
echo $APP_DIR;

if [ -d $APP_DIR ];then
echo $APP_NAME' was installed at:';
echo $APP_DIR;
exit 0;
else
mkdir $APP_DIR;
fi

if [ ! -z $2 ];then
APP_TEMPLATE=$2;
fi
echo $APP_TEMPLATE;
mkdir -p $APP_DIR/logs;

if [ $APP_TEMPLATE = 'tomcat' ];then
mkdir -p $APP_DIR/apps;
#TODO download from remote or copy form loal
elif [ $APP_TEMPLATE = 'nginx' ];then
mkdir -p $APP_DIR/conf.d;
#TODO download from remote or copy form loal
elif [ $APP_TEMPLATE = 'java' ];then
mkdir -p $APP_DIR/apps;
#TODO download from remote or copy form loal
else
echo 'Unkwon template of application at argument 2.(tomcat|nginx. default tomcat)';
rm -rf $APP_DIR;
fi