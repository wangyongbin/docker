#!/bin/sh
# 当前路径
BASE_PATH=~/docker_deploy

# 非托管应用配置文件目录
APPS_PATH=$BASE_PATH/conf/unmanaged

# 非托管应用配置文件挂载路径

MOUNT_PATH=/home/docker/docker_deploy/conf/unmanaged

SERVICE_NAME=$1
SERVICE_URL=$2

# 创建应用配置文件目录
create_app_config_dir (){

	if [ ! -d $1 ];then
		mkdir $1
	fi

}


# 创建应用配置文件
create_app_config_service (){

echo "#[required]service name
SERVICE_NAME='$1'

#[required]service type
SERVICE_TYPE='nginx'

#[required]service image
SERVICE_IMAGE='nginx-basic:1.0'

#[required]service local path.
SERVICE_LOCAL_PATH='$2'

#[option]service publish
SERVICE_PUBLISH=''

#[option]service network
SERVICE_NETWORK=(vlan_app)

#[option]service constraint
SERVICE_CONSTRAINT='node.role==manager'

#[option]service replicas
SERVICE_REPLICAS=1" > $3;

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

# 检查文件是否生成
check_app_config_service_exist (){

	if [ ! -f $1 ];then
		echo "Configuration file generation failed.";
		exit 1; # 配置文件生成失败
	fi


}

# 检测文件是否存在
check_app_config_default_exist (){

	if [ ! -f $1 ];then
        	echo "Configuration file generation failed.";
                exit 1; # 配置文件生成失败
        fi

}

create_app_config_dir $APPS_PATH/$SERVICE_NAME

create_app_config_service $SERVICE_NAME $MOUNT_PATH/$SERVICE_NAME/$SERVICE_NAME.conf $APPS_PATH/$SERVICE_NAME/service.conf

create_app_unmanaged $SERVICE_URL $APPS_PATH/$SERVICE_NAME/$SERVICE_NAME.conf

check_app_config_service_exist $APPS_PATH/$SERVICE_NAME/service.conf

check_app_config_default_exist $MOUNT_PATH/$SERVICE_NAME/$SERVICE_NAME.conf