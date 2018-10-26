#!/bin/bash

# step1 安装所需工具
sudo apt-get -y install apt-transport-https ca-certificates curl software-properties-common

sudo apt-get -y install apt-transport-https ca-certificates curl software-properties-common

# step2 安装GPG证书
curl -fsSL http://mirrors.aliyun.com/docker-ce/linux/ubuntu/gpg | sudo apt-key add -


# step3 设置稳定的存储库
sudo add-apt-repository "deb [arch=amd64] http://mirrors.aliyun.com/docker-ce/linux/ubuntu $(lsb_release -cs) stable"

# step4 更新并安装 docker-ce
# apt-cache madison docker-ce 查看版本
sudo apt-get update
sudo apt-get -y install docker-ce=18.03.0~ce-0~ubuntu

# step5 系统自启
sudo systemctl enable docker