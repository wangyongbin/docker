#!/bin/sh
#
# 命令:
#   sudo sh swarm-agent.sh [HOST_IP] [SWARM_ROLE] [CONSUL_IP] 
# 参数解释： 
#  HOST_IP  主机IP地址
#  SWARM_ROLE  两种角色 manager worker
#

#set -e
#变量
HOST_IP=${1}
SWARM_ROLE=${2}
CONSUL_IP=${3}
container_name=swarm_agent

##
#echo "--- Download consul:latest Image ---"
#docker pull swarm:latest

##
docker inspect --format '{{.Name}}' ${container_name}
if [ $? -eq 0 ]; then 
	docker stop ${container_name} && docker rm -fv ${container_name}
fi

echo "--- Swarm ${SWARM_ROLE} Agent Install ---"
if [ "manager" = "${SWARM_ROLE}" ]; then
docker run -d \
	--restart=always \
	--name ${container_name} \
	-p 3375:3375 \
	swarm manage -H :3375 --replication --advertise ${HOST_IP}:3375 consul://${CONSUL_IP}:8500
	echo "--- Swarm ${SWARM_ROLE} Agent Install Success!!! ---"
elif [ "worker" = "${SWARM_ROLE}" ]; then
docker run -d \
	--restart=always \
	--name ${container_name} \
	swarm join --advertise ${HOST_IP}:2375 consul://${CONSUL_IP}:8500
	echo "--- Swarm ${SWARM_ROLE} Agent Install Success!!! ---"
fi
