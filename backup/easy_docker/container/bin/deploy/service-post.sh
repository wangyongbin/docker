#!/bin/sh

SERVICE_NAME=$1

if [ $1 = '--help' ];then
        echo 'Commond for example:./service-post.sh [ServiceName].';
        exit 0;
fi

SLEEP_SECOND=5

REPLICAS=$(docker service ls | grep $SERVICE_NAME | awk '{print $4}')
if [ -z $REPLICAS ];then

        echo "服务 $SERVICE_NAME 不存在"

        exit 1
fi

for i in 1 2 3 4 5 6
do

        sleep $SLEEP_SECOND

        REPLICAS=$(docker service ls | grep $SERVICE_NAME | awk '{print $4}')

        RESULT=${REPLICAS:0:1}

        if [ $RESULT = 0 ];then

                # 检测服务是否启动，未启动，则暂停5秒
                echo "服务 $SERVICE_NAME 第 $i 次启动失败"

#               sleep $SLEEP_SECOND

        elif [ $RESULT = 1 ];then
                # 检测服务启动成功，则暂停1秒再检查一次是否启动成功
                sleep 1

                REPLICAS=$(docker service ls | grep $SERVICE_NAME | awk '{print $4}')

                RESULT=${REPLICAS:0:1}
                if [ $RESULT = 1 ];then
                        echo "服务 $SERVICE_NAME 第 $i 次启动成功"
                        exit 0;
                fi
        fi
done