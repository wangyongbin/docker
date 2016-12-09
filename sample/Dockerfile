FROM ubuntu:14.04
MAINTAINER wyb
ENV REFRESHED_AT 2016_12_09
RUN echo 'deb http://mirrors.aliyun.com/ubuntu/ trusty main restricted universe multiverse \n deb-src http://mirrors.aliyun.com/ubuntu/ trusty main restricted universe multiverse ' | sudo tee /etc/apt/sources.list
RUN apt-get -yqq update && apt-get install -y nginx
RUN mkdir -p /var/www/html/website
ADD nginx/global.conf /etc/nginx/conf.d/
ADD nginx/nginx.conf /etc/nginx/nginx.conf
EXPOSE 80
