

FROM nginx:latest

#环境变量
ENV CONSUL_URL consul:8500
ENV CONSUL_TEMPLATE_PATH /coss/nginx/templates
ENV CONSUL_TEMPLATE_SOURCE nginx.conf.ctmpl
ENV CONSUL_TEMPLATE_TARGET /etc/nginx/conf.d/default.conf
#1,新建文件夹保存模板文件 
#2,添加 consul-template.sh,请先下载
#3,添加 模板文件 nginx.conf.ctmpl
RUN mkdir -p /coss/nginx/templates
ADD consul-template /usr/sbin/
ADD nginx.conf.ctmpl /coss/nginx/templates/

CMD /usr/sbin/nginx -c /etc/nginx/nginx.conf & consul-template -consul=$CONSUL_URL -template="$CONSUL_TEMPLATE_PATH/$CONSUL_TEMPLATE_SOURCE:$CONSUL_TEMPLATE_TARGET:/usr/sbin/nginx -s reload"
EXPOSE 80
