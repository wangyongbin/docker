FROM nginx:latest

RUN mkdir /templates

#模板文件
ENV TEMPLATE_FILE /templates/service.ctmpl 

RUN rm -v /etc/nginx/conf.d/*

#模板文件生成的配置文件
ENV CONFIG_FILE /etc/nginx/conf.d/service.conf 

#Consul 访问地址CONSUL_URL和服务名称SERVICE_NAME
ENV CONSUL_URL consul:8500
ENV SERVICE_NAME consul-8500

#添加consul-template.sh,请先下载
ADD consul-template /usr/local/bin/

# Command will
# 1. 生成 Consul 模板文件
# 2. 启动 nginx
# 3. 生成 配置文件
CMD echo "upstream app {				                                \n\
	least_conn;				                                        \n\
	{{range service \"$SERVICE_NAME\"}}						\n\
		server {{.Address}}:{{.Port}} max_fails=3 fail_timeout=60 weight=1;	\n\
	{{else}}server 127.0.0.1:65535; # force a 502{{end}}				\n\
}											\n\
											\n\
server {										\n\
	listen 80 default_server;							\n\
	charset utf-8;									\n\
	location / {									\n\
		proxy_pass http://app;							\n\
		proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;		\n\
		proxy_set_header Host \$host;						\n\
		proxy_set_header X-Real-IP \$remote_addr;				\n\
	}										\n\
}" > $TEMPLATE_FILE; /usr/sbin/nginx -c /etc/nginx/nginx.conf & CONSUL_TEMPLATE_LOG=debug consul-template -consul=$CONSUL_URL -template="$TEMPLATE_FILE:$CONFIG_FILE:/usr/sbin/nginx -s reload"

EXPOSE 80
