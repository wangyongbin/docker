

#!/bin/sh
#
# 命令:
#   sudo sh consul-agent.sh [HOST_IP] [CONSUL_NODE_NAME] [CONSUL_ROLE] [JOIN_IP] 
# 参数解释： 
#  HOST_IP : 主机IP地址
#  CONSUL_NODE_NAME : consul agent 在集群中的名称
#  CONSUl_ROLE : 三种角色 master server client
#  JOIN_IP : 用于server、client 角色加入到master为主的集群中

#set -e
#变量
HOST_IP=${1}
CONSUL_NODE_NAME=${2}
CONSUL_ROLE=${3}
JOIN_IP=${4}
container_name=consul_agent
registrator=registrator

##
docker inspect --format '{{.Name}}' ${container_name}
if [ $? -eq 0 ]; then 
	docker stop ${container_name} && docker rm -fv ${container_name}
	rm -fr /consul/*
fi

echo "--- Download Image: consul:latest AND Install ---"
#docker pull consul:latest

echo "--- Consul ${CONSUL_ROLE} Agent Install ---"
if [ "master" = "${CONSUL_ROLE}" ]; then
	docker run -d \
		--restart=always \
		--name="${container_name}" \
		-p 8300:8300/tcp \
		-p 8400:8400/tcp \
		-p 8500:8500/tcp \
		-p 8600:8600/tcp \
		-p 8600:8600/udp \
		-p 8301:8301/tcp \
		-p 8301:8301/udp \
		-p 8302:8302/tcp \
		-p 8302:8302/udp \
		-v /consul/data:/consul/data \
		-e 'CONSUL_LOCAL_CONFIG={"skip_leave_on_interrupt": true,"ui": true,"client_addr": "0.0.0.0"}' \
		consul agent -server -advertise=${HOST_IP} -bootstrap -node=${CONSUL_NODE_NAME}
	echo "--- Consul ${CONSUL_ROLE} Agent Install Success!!! ---"
elif [ "server" = "${CONSUL_ROLE}" ]; then
	docker run -d \
		--restart=always \
		--name="${container_name}" \
		-p 8300:8300/tcp \
		-p 8400:8400/tcp \
		-p 8500:8500/tcp \
		-p 8600:8600/tcp \
		-p 8600:8600/udp \
		-p 8301:8301/tcp \
		-p 8301:8301/udp \
		-p 8302:8302/tcp \
		-p 8302:8302/udp \
		-v /consul/data:/consul/data \
		-e 'CONSUL_LOCAL_CONFIG={"skip_leave_on_interrupt": true,"ui": true,"client_addr": "0.0.0.0"}' \
		consul agent -server -advertise=${HOST_IP} -retry-join=${JOIN_IP} -node=${CONSUL_NODE_NAME}
	echo "--- Consul ${CONSUL_ROLE} Agent Install Success!!! ---"
elif [ "client" = "${CONSUL_ROLE}" ]; then
	docker run -d \
		--restart=always \
		--name="${container_name}" \
		--net=host \
		-v /consul/data:/consul/data \
		-v /consul/config:/consul/config \
		-e 'CONSUL_LOCAL_CONFIG={"leave_on_terminate": true,"ui": true,"client_addr":"0.0.0.0"}' \
		consul agent -advertise=${HOST_IP} -retry-join=${JOIN_IP} -node=${CONSUL_NODE_NAME}

	echo "--- Download Image: gliderlabs/registrator:latest AND install ---"
	#docker pull gliderlabs/registrator:latest
	docker inspect --format '{{.Name}}' ${registrator}
	if [ $? -eq 0 ]; then 
		docker stop ${registrator} && docker rm -fv ${registrator}
	fi
	echo "--- Auto Registrator Install ---"
	docker run -d \
		--restart=always \
		--name registrator\
		-v /var/run/docker.sock:/tmp/docker.sock \
		gliderlabs/registrator consul://${HOST_IP}:8500
	echo "--- Consul ${CONSUL_ROLE} Agent Install Success!!! ---"
fi

