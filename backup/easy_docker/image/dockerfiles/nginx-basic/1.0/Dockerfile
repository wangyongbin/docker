FROM nginx:1.13.5-alpine

RUN sed -i 's#/var/log/nginx/error.log#/app_vol/logs/error.log#g' /etc/nginx/nginx.conf && sed -i 's#/var/log/nginx/access.log#/app_vol/logs/access.log#g' /etc/nginx/nginx.conf && sed -i 's#/etc/nginx/conf.d#/app_vol/conf.d#g' /etc/nginx/nginx.conf 

EXPOSE 80
STOPSIGNAL SIGTERM
CMD ["nginx", "-g", "daemon off;"]
