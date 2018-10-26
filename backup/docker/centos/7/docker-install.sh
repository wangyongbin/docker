#!/bin/bash

#
docker_version=17.03.0.ce

# step1
yum install -y yum-utils device-mapper-persistent-data lvm2

yum-config-manager --add-repo http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo

yum makecache fast

# step2
#
# yum list docker-ce --showduplicates | sort -r
yum install -y docker-ce-${docker_version}
#yum install -y docker-ce-17.09.0.ce

vi /etc/docker/daemon.json

# step3
systemctl start docker

# step4
systemctl enable docker


{
"debug":true,
"registry-mirrors": ["https://registry.docker-cn.com"],
"storage-driver":"overlay",
"data-root":"/home/docker/docker_data",
"insecure-registries":[ "http://registry.ib2000.net:50001"]
}