FROM ubuntu:14.04
MAINTAINER wyb
RUN echo 'deb http://mirrors.aliyun.com/ubuntu/ trusty main restricted universe multiverse \n deb-src http://mirrors.aliyun.com/ubuntu/ trusty main restricted universe multiverse ' | sudo tee /etc/apt/sources.list
RUN apt-get update && apt-get install -y apache2
ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_LOG_DIR /var/log/apache2
ONBUILD ADD . /var/www
EXPOSE 80
ENTRYPOINT ["/usr/sbin/apache2"]
CMD ["-D","FOREGROUND"]
