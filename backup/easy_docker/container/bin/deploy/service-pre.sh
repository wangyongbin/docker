#!/bin/sh
# 当前路径
BASE_PATH=~/docker_deploy

# 应用配置目录
BASE_CONF_PATH=/home/docker/docker_deploy/conf

# 应用文件挂载目录
MOUNT_PATH=/home/docker/docker_data/volumes/resource_app/_data;

# 应用配置文件目录


TYPE=$1
SERVICE_NAME=$2
SERVICE_TYPE=$3
FILE_NAME=$4

if [ $1 = '--help' ];then
	echo 'Commond for example:./service-pre.sh <managed|unmanaged> <ServiceName> <java|tomcat|nginx> [FileName | Url].';
	exit 0;
fi

# 创建应用配置文件目录
create_app_config_dir (){

	if [ ! -d $1 ];then
		mkdir $1
	fi

}


# 生成配置文件
create_app_config_service (){

echo "#[required]service name
SERVICE_NAME='$1'

#[required]service type
SERVICE_TYPE='$2'

#[required]service image
SERVICE_IMAGE='$2-basic:1.0'

#[required]service local path.
SERVICE_LOCAL_PATH='$3'

#[option]service publish
SERVICE_PUBLISH=''

#[option]service network
SERVICE_NETWORK=(vlan_app)

#[option]service constraint
SERVICE_CONSTRAINT='node.role==manager'

#[option]service replicas
SERVICE_REPLICAS=1" > $4/service.conf;

}


# 检测文件是否存在
check_app_file_exist (){

	if [ ! -f $1 ];then
		echo "File not found : $FULL_FILE_NAME.";
		exit 1;
	fi

}

# 检测配置文件是否存在
check_app_config_file_exist (){

	if [ ! -f $1/service.conf ];then

        	echo "Configuration file $1/service.conf generation failed.";
                exit 1; # 配置文件生成失败

        fi

}

# 检测非托管服务文件是否创建成功
check_app_unmanaged_file_exist (){

	if [ ! -f $1 ];then
        	echo "Configuration file $1 generation failed.";
                exit 1; # 配置文件生成失败
        fi

}

# 非托管应用信息
create_app_unmanaged (){

echo "
server {
    listen       80;
    server_name  localhost;

    location / {
	proxy_set_header Host \$host:\$server_port;
	rewrite ^/ $1 redirect;
    }
}" > $2

}

# 判断类型是否为托管服务
if [ $TYPE = 'managed' ];then

	# 应用文件+路径
	FULL_FILE_NAME=$MOUNT_PATH/$FILE_NAME

	# 配置文件路径
	FULL_CONF_PATH=$BASE_CONF_PATH/$TYPE/$SERVICE_NAME

	if [ $SERVICE_TYPE = 'java' ];then

		# 检测应用文件是否存在
		check_app_file_exist $FULL_FILE_NAME

		# 创建服务目录
		create_app_config_dir $FULL_CONF_PATH

		# 创建配置文件
		create_app_config_service $SERVICE_NAME $SERVICE_TYPE $FULL_FILE_NAME $FULL_CONF_PATH

		# 检测应用配置是否创建成功
		check_app_config_file_exist $FULL_CONF_PATH

	elif [ $SERVICE_TYPE = 'tomcat' ];then

		# 检测应用文件是否存在
		check_app_file_exist $FULL_FILE_NAME

		# 创建服务目录
		create_app_config_dir $APPS_PATH/$SERVICE_NAME

		# 创建配置文件
		create_app_config_service $SERVICE_NAME $SERVICE_TYPE $FULL_FILE_NAME $FULL_CONF_PATH

		# 检测应用配置是否创建成功
		check_app_config_file_exist $FULL_CONF_PATH

	else

		echo 'Not support service type';
		exit 1;

	fi

elif [ $TYPE = 'unmanaged' ];then

	# 非托管服务类型默认nginx，并追加配置文件 $SERVICE_NAME.conf
	SERVICE_TYPE="nginx"

	# 配置文件路径
	FULL_CONF_PATH=$BASE_CONF_PATH/$TYPE/$SERVICE_NAME

	# 非托管服务nginx配置文件名称
	FULL_FILE_NAME=$BASE_CONF_PATH/$TYPE/$SERVICE_NAME/$SERVICE_NAME.conf

	# 创建服务目录
	create_app_config_dir $FULL_CONF_PATH

	# 创建配置文件
	create_app_config_service $SERVICE_NAME $SERVICE_TYPE $FULL_FILE_NAME $FULL_CONF_PATH

	# 非托管服务信息 $FILE_NAME
	create_app_unmanaged $FILE_NAME $FULL_FILE_NAME

	# 检测应用配置是否创建成功
	check_app_config_file_exist $FULL_CONF_PATH

	# 检测非托管服务文件是否创建成功
	check_app_unmanaged_file_exist $FULL_FILE_NAME

else

	echo 'Unknown type';
	exit 1;

fi