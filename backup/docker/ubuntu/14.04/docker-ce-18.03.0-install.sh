#!/bin/bash

# step1
sudo apt-get -y install linux-image-extra-$(uname -r) linux-image-extra-virtual

# step2
sudo apt-get -y install apt-transport-https ca-certificates curl software-properties-common

# step3 安装GPG证书
curl -fsSL http://mirrors.aliyun.com/docker-ce/linux/ubuntu/gpg | sudo apt-key add -

##验证
#sudo apt-key fingerprint 0EBFCD88

# step4 设置稳定的存储库
sudo add-apt-repository "deb [arch=amd64] http://mirrors.aliyun.com/docker-ce/linux/ubuntu $(lsb_release -cs) stable"

# step5 更新并安装 docker-ce
# apt-cache madison docker-ce 查看版本
sudo apt-get update
sudo apt-get -y install docker-ce=18.03.0~ce-0~ubuntu

# step6 系统自启
sudo systemctl enable docker