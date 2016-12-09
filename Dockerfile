FROM ubuntu:14.04
MAINTAINER wyb
RUN echo -e '
	deb http://mirrors.aliyun.com/ubuntu/ trusty main restricted universe multiverse \n
	deb http://mirrors.aliyun.com/ubuntu/ trusty-security main restricted universe multiverse \n
	deb http://mirrors.aliyun.com/ubuntu/ trusty-updates main restricted universe multiverse \n
	deb http://mirrors.aliyun.com/ubuntu/ trusty-proposed main restricted universe multiverse \n
	deb http://mirrors.aliyun.com/ubuntu/ trusty-backports main restricted universe multiverse \n
	## aliyun \n
	deb-src http://mirrors.aliyun.com/ubuntu/ trusty main restricted universe multiverse \n
	deb-src http://mirrors.aliyun.com/ubuntu/ trusty-security main restricted universe multiverse \n
	deb-src http://mirrors.aliyun.com/ubuntu/ trusty-updates main restricted universe multiverse \n
	deb-src http://mirrors.aliyun.com/ubuntu/ trusty-proposed main restricted universe multiverse \n
	deb-src http://mirrors.aliyun.com/ubuntu/ trusty-backports main restricted universe multiverse \n 
	' | sudo tee /etc/apt/sources.list
RUN apt-get update && apt-get install -y nginx
RUN echo 'Hi, I am in your container' \ 
	>/usr/share/nginx/html/index.html
EXPOSE 80
