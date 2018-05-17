docker volume create vol_mysql

docker run -d --restart=always \
--name dev-mysql \
-e MYSQL_ROOT_PASSWORD=123456 \
-v vol_mysql:/var/lib/mysql \
-p 3306:3306 \
mysql:5.6
