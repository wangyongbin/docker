FROM ubuntu:14.04

RUN echo -e 'deb http://nginx.org/packages/ubuntu/ trusty nginx \n deb-src http://nginx.org/packages/ubuntu/  trusty nginx' > /etc/apt/sources.list.d/nginx.list

RUN apt-get -yqq update && apt-get -yqq install nginx

VOLUME /etc/nginx/conf.d/
VOLUME /etc/nginx/certs/

EXPOSE 80,8080,443,8443

CMD service nginx start && tail -f /var/log/nginx/access.log
