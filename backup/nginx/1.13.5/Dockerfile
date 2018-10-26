FROM nginx:1.13.5-alpine

RUN mkdir -p /app_vol/apps \
    && mkdir -p /app_vol/logs \
    && cp /etc/nginx/conf.d/default.conf /app_vol/apps/default.conf \
    && sed -i 's#/var/log/nginx/error.log#/app_vol/logs/error.log#g' /etc/nginx/nginx.conf \
    && sed -i 's#/var/log/nginx/access.log#/app_vol/logs/access.log#g' /etc/nginx/nginx.conf \
    && sed -i 's#/etc/nginx/conf.d#/app_vol/apps#g' /etc/nginx/nginx.conf \
    && ln -sf /dev/stdout /app_vol/logs/access.log \
	&& ln -sf /dev/stderr /app_vol/logs/error.log

COPY Shanghai /usr/share/zoneinfo/Asia/Shanghai
RUN ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && mkdir -p /docker/version

COPY apps/ /app_vol/apps
COPY version/ /docker/version


EXPOSE 80
STOPSIGNAL SIGTERM
CMD ["nginx", "-g", "daemon off;"]
