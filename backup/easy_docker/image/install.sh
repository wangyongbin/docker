#!/bin/bash
#使用Dockerfile安装镜像,并将镜像推送至私有镜像库中.

#获取当前路径的绝对路径访问地址.
CURR_PATH=$(pwd);

#初始化镜像基础路径,一般为sh文件当前路径.
IMAGE_BASE=$CURR_PATH;

#初始化Dockerfile的基础路径,一般为镜像基础路径下的dockerfiles路径
DOCKERFILES_BASE=$IMAGE_BASE/dockerfiles;



source registry.conf;

# DOCKERFILE_SOURCE_REPO='';

#echo $IMAGE_BASE;
#echo $DOCKERFILES_BASE;

function image_build ()
{

	ARG_1=$1;
	ARG1_ARRY=(${ARG_1//:/ });

	if [ ! ${#ARG1_ARRY[*]} = 2 ];then
		echo 'Image name must be "ImageName[:(version|tag)]".';
	exit 1;
	fi

	IMAGE_NAME=$1;
	IMAGE_NAME_FULL=$IMAGE_NAME;
	if [ ! -z $IMAGE_REGISTRY ];then
		IMAGE_NAME_FULL=$IMAGE_REGISTRY$IMAGE_NAME;
	fi

#echo $IMAGE_NAME_FULL;

	IMAGE_PATH=${ARG1_ARRY[0]}'/'${ARG1_ARRY[1]};

#echo $IMAGE_NAME;
#echo $IMAGE_PATH;

	IMAGE_DOCKERFILE_PATH_DIR=$DOCKERFILES_BASE/$IMAGE_PATH;
	IMAGE_DOCKERFILE_PATH_FULL=$IMAGE_DOCKERFILE_PATH_DIR/Dockerfile;
#echo $IMAGE_DOCKERFILE_PATH_FULL;

	CMD_DOCKER_BUILD='docker build -t '$IMAGE_NAME_FULL' '$IMAGE_DOCKERFILE_PATH_DIR;
	# echo $CMD_DOCKER_BUILD;
	eval $CMD_DOCKER_BUILD;

	image_push $IMAGE_NAME_FULL;
}


function image_push()
{
	IMAGE_NAME_FULL=$1;
	CMD_DOCKER_PUSH='docker push '$IMAGE_NAME_FULL;
	# echo $CMD_DOCKER_PUSH;
	eval $CMD_DOCKER_PUSH;
}

function foreach_dockerfiles()
{
	SED_BEGIN_PARTTEN="'s#$DOCKERFILES_BASE/##g'";
	SED_END_PARTTEN="s#/Dockerfile##g";
	SED_SPLIT_PARTTEN="s#/#:#g";
	CMD_DOCKERFILES_FIND="find "$DOCKERFILES_BASE" -name Dockerfile|sed "$SED_BEGIN_PARTTEN"|sed "$SED_END_PARTTEN"|sed "$SED_SPLIT_PARTTEN;
	echo $CMD_DOCKERFILES_FIND;
	eval $CMD_DOCKERFILES_FIND > image.list;

	cat image.list | while read LINE
		do
			echo '================'$LINE' Build && Push start===============';
			image_build $LINE;
			echo '================='$LINE' Build && Push end================';
		done
		rm image.list;
}


if [[ $1 = '--help' ]]; then
	echo 'Commond for example:./install.sh [ImageName:ImageVersion].';
	exit 0;
fi

if [ -z $1 ];then
	read -p 'You will build image for all,please ensure:(Press "Y" to continue,or press any key to abort.)' SEL_OPT;

	if [ ! $SEL_OPT = 'y' ];then
		exit 0;
	fi
	foreach_dockerfiles;
else
	image_build $1;
fi
