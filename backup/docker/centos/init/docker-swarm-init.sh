#!/bin/bash
# Docker swarm init by docker
# step1 docker swarm init
# step2 swarm subnet create
# step3 create basic services

#
ui_version=1.17.1
ui_port=60001

# step1
read -p "Input your IP Address to create swarm manager." IP_Address

echo "初始化docker swarm"
docker swarm init --advertise-addr $IP_Address > swarm_token

# step2
echo "创建子网"
docker network create --driver overlay --subnet 10.1.0.0/24 vlan_console
docker network create --driver overlay --subnet 10.1.1.0/24 vlan_coss
docker network create --driver overlay --subnet 10.1.2.0/24 vlan_daemon
docker network create --driver overlay --subnet 10.2.0.0/16 vlan_app

# step3
# 创建基础服务
# 基础服务镜像列表
# portainer/portainer docker 可视化镜像

echo "创建 docker ui"
docker volume create vol_console
docker service create --name swarm_console --publish ${ui_port}:9000 \
--network vlan_daemon \
--constraint 'node.role == manager' \
--mount type=bind,src=/var/run/docker.sock,dst=/var/run/docker.sock \
--mount type=volume,source=vol_console,destination=/data \
portainer/portainer:${ui_version} \
-H unix:///var/run/docker.sock