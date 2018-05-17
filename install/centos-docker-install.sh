#!/bin/bash

# 安装工具
sudo yum install -y yum-utils device-mapper-persistent-data lvm2

# 设置docker源
sudo yum-config-manager --add-repo http://download.docker.com/linux/centos/docker-ce.repo

# 更新源
sudo yum makecache fast

# 安装docker
sudo yum install docker-ce

# 当前用户加入到docker组
sudo usermod -aG docker $USER

# 设置开机启动
sudo systemctl enable docker

# 启动docker
sudo systemctl start docker

