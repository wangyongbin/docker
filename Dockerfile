FROM ubuntu:14.04
MAINTAINER wyb
RUN echo 'deb http://mirrors.aliyun.com/ubuntu/ trusty main restricted universe multiverse \n deb-src http://mirrors.aliyun.com/ubuntu/ trusty main restricted universe multiverse ' | sudo tee /etc/apt/sources.list
RUN apt-get update
RUN apt-get install -y nginx
RUN echo 'Hi, I am in your container' \ 
	> /usr/share/nginx/html/index.html
EXPOSE 80
