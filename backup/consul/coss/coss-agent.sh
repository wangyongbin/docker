#!/bin/sh
#
# 命令:
#   sudo sh consul-agent.sh [HOST_IP] [COSS_AGENT_NAME] [COSS_ROLE] [JOIN_IP] 
# 参数解释： 
#  HOST_IP : 主机IP地址
#  COSS_AGENT_NAME : COSS Agent 在集群中的名称
#  COSS_ROLE : 三种角色 bootstrap magager worker
#  JOIN_IP : 用于magager、worker 角色加入到 bootstrap 为主的集群中

#set -e
#变量
HOST_IP=${1}
COSS_AGENT_NAME=${2}
COSS_ROLE=${3}
JOIN_IP=${4}
CONSUL_AGENT=consul_agent
AUTO_REGITRY=registrator
SWARM_AGENT=swarm_agent

## Download Image : consul | swarm | gliderlabs/registrator
#echo "--- Download Image: consul:latest AND Install ---"
#docker pull consul:latest

#echo "--- Download swarm:latest Image ---"
#docker pull swarm:latest

#echo "--- Download Image: gliderlabs/registrator:latest AND install ---"
#docker pull gliderlabs/registrator:latest

##

##
# check swarm agent if install 
if docker inspect ${SWARM_AGENT} >/dev/null 2>&1; then 
	docker stop ${SWARM_AGENT} && docker rm -fv ${SWARM_AGENT}
fi

# check auto registry if install
if docker inspect ${AUTO_REGITRY} >/dev/null 2>&1; then 
	docker stop ${AUTO_REGITRY} && docker rm -fv ${AUTO_REGITRY}
fi

# check consul agent if install 
if docker inspect ${CONSUL_AGENT} >/dev/null 2>&1; then 
	docker stop ${CONSUL_AGENT} && docker rm -fv ${CONSUL_AGENT}
	rm -fr /consul/*
fi


echo "--- COSS ${COSS_ROLE} Agent Install ... ---"
if [ "bootstrap" = "${COSS_ROLE}" ]; then
	echo "--- Consul Agent Install ... ---"
	docker run -d \
		--restart=always \
		--name="${CONSUL_AGENT}" \
		--net=host \
		-v /consul/data:/consul/data \
		-e 'CONSUL_LOCAL_CONFIG={"skip_leave_on_interrupt": true,"server": true,"ui": true,"client_addr": "0.0.0.0"}' \
		consul agent -bind=${HOST_IP} -bootstrap -node=${COSS_AGENT_NAME}

	echo "--- Swarm Agent Install ... ---"
	docker run -d \
		--restart=always \
		--name ${SWARM_AGENT} \
		-p 3375:2375 \
		swarm manage --replication --advertise ${HOST_IP}:3375 consul://${HOST_IP}:8500

	echo "--- COSS ${COSS_ROLE} Agent Install Success!!! ---"
elif [ "manager" = "${COSS_ROLE}" ]; then
	echo "--- Consul Agent Install ... ---"
	docker run -d \
		--restart=always \
		--name="${CONSUL_AGENT}" \
		--net=host \
		-v /consul/data:/consul/data \
		-e 'CONSUL_LOCAL_CONFIG={"skip_leave_on_interrupt": true,"server": true,"ui": true,"client_addr": "0.0.0.0"}' \
		consul agent -bind=${HOST_IP} -join=${JOIN_IP} -node=${COSS_AGENT_NAME}

	echo "--- Swarm Agent Install ---"
	docker run -d \
		--restart=always \
		--name ${SWARM_AGENT} \
		-p 3375:2375 \
		swarm manage --replication --advertise ${HOST_IP}:3375 consul://${HOST_IP}:8500

	echo "--- COSS ${COSS_ROLE} Agent Install Success!!! ---"
elif [ "worker" = "${COSS_ROLE}" ]; then
    echo "--- Consul Agent Install ... ---"
	docker run -d \
		--restart=always \
		--name="${CONSUL_AGENT}" \
		--net=host \
		-v /consul/data:/consul/data \
		-v /consul/config:/consul/config \
		-e 'CONSUL_LOCAL_CONFIG={"leave_on_terminate": true,"server": false,"ui": true,"client_addr":"0.0.0.0"}' \
		consul agent -bind=${HOST_IP} -join=${JOIN_IP} -node=${COSS_AGENT_NAME}

	
	echo "--- Auto Registry Install ---"
	docker run -d \
		--restart=always \
		--name ${AUTO_REGITRY} \
		-v /var/run/docker.sock:/tmp/docker.sock \
		gliderlabs/registrator consul://${HOST_IP}:8500

	echo "--- Swarm Agent Install ---"
	docker run -d \
		--restart=always \
		--name ${SWARM_AGENT} \
		swarm join --advertise ${HOST_IP}:2375 consul://${HOST_IP}:8500

	echo "--- COSS ${COSS_ROLE} Agent Install Success!!! ---"
fi