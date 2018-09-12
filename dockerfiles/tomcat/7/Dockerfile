FROM tomcat:7.0-jre7-alpine

ENV CATALINA_HOME /usr/local/tomcat

# 更改时区
RUN sed -i 's#dl-cdn.alpinelinux.org#mirrors.aliyun.com#g' /etc/apk/repositories \
    && apk update \
    && apk add --no-cache \
    && apk add curl bash tree tzdata \
    && ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && echo "Asia/Shanghai" > /etc/timezone

EXPOSE 8080

ADD entrypoint.sh $CATALINA_HOME/bin/entrypoint.sh
CMD entrypoint.sh