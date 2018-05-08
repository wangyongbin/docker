#!/bin/bash

sudo yum install -y yum-utils device-mapper-persistent-data lvm2

sudo yum-config-manager --add-repo http://download.docker.com/linux/centos/docker-ce.repo

sudo yum makecache fast

sudo yum install docker-ce

sudo systemctl start docker
