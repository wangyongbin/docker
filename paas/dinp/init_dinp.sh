####https://leo108.com/pid-2109/

# step 1 install jenkins
# step 2 install registry
# step 3 install memcached
# step 4 install redis
# step 5 install mysql
# step 6 init database to mysql
# step 7 install uic  在启动 UIC 之前需要在mysql数据库中新建uic库和表 dinp_uic.sql
# step 8 install builder  在启动 builder 之前需要在mysql数据库中新建builder库和表 dinp_builder.sql
# step 9 install server
# step 10 install agent
# step 11 install dashboard
# step 12 install router
# step 13 install scribe Scribe是facebook开源的一个日志收集软件，Dinp使用scribe来收集各个Paas Container产生的日志文件，例如access_log，这样不会因为容器的销毁导致日志丢失

# init data dir

mkdir -p $HOME/dinp/data/jenkins
mkdir -p $HOME/dinp/data/registry
mkdir -p $HOME/dinp/data/mysql
mkdir -p $HOME/dinp/data/scribe

# install  jenkins

docker run -d --name jenkins -p 8089:8080 \
-v $HOME/dinp/data/jenkins:/var/jenkins_home \
-v /usr/bin/docker/:/usr/bin/docker \
-v /var/run/docker.sock:/var/run/docker.sock -u root \
ttthzy/dinp_jenkins

# install registry

docker run -d --name registry -p 5000:5000 \
-v $HOME/dinp/data/registry:/tmp/registry \
ttthzy/dinp_registry

# memcached
docker run -d --name memcached ttthzy/dinp_memcached

# redis
docker run --name redis -d -p 6379:6379 ttthzy/dinp_redis

# mysql

docker run -d --name mysql -p 3306:3306 \
-v $HOME/dinp/data/mysql:/var/lib/mysql \
-e MYSQL_ROOT_PASSWORD=123456 \
ttthzy/dinp_mysql



# UIC
docker run -d --name uic -p 8080:8080 \
--link memcached:memcached \
--link mysql:mysql \
-e DB_NAME=uic \
-e DB_USER=root \
-e DB_PWD=123456 \
-e UIC_TOKEN=123456 \
ttthzy/dinp_uic


# builder

docker run -d --name dinp_builder -p 7788:7788 \
--link mysql:mysql \
-e DB_NAME=builder \
-e DB_USER=root \
-e DB_PWD=123456 \
-e UIC_URL=http://192.144.175.79:8080 \
-e UIC_TOKEN=123456 \
-e REGISTRY_URL=192.144.175.79:5000 \
-v /var/run/docker.sock:/var/run/docker.sock \
-v /usr/bin/docker:/usr/bin/docker \
ttthzy/dinp_builder

# server
### 在启动 server 之前需要在mysql数据库中新建dash库和表 DINP_MYSQL_DASH
docker run -d --name dinp_server \
--link mysql:mysql \
--link redis:redis \
--link scribe:scribe \
-e DB_USER=root \
-e DB_PWD=123456 \
-e DB_NAME=dash \
-e DOMAIN=dinp.leo108.com \
-p 1980:1980 \
-p 1970:1970 \
ttthzy/dinp_server



### dashboard

docker run -d --name dinp_dash -p 8082:8080 \
--link mysql:mysql \
--link memcached:memcached \
-e DB_NAME=dash \
-e DB_USER=root \
-e DB_PWD=123456 \
-e UIC_URL=http://192.144.175.79:8080 \
-e UIC_TOKEN=123456 \
-e BUILDER_URL=http://192.144.175.79:7788 \
-e SERVER_URL=http://192.144.175.79:1980 \
-e DOMAIN=dinp.leo108.com \
ttthzy/dinp_dashboard

### agent

docker run -d --name dinp_agent \
-e SERVER_HOST=192.144.175.79 \
-e SERVER_PORT=1970 \
-e AGENT_IP=192.144.175.79 \
-v /var/run/docker.sock:/var/run/docker.sock \
-v /usr/bin/docker:/usr/bin/docker \
ttthzy/dinp_agent


### router

docker run -d --name dinp_router \
-p 8083:8082 \
-p 80:8888 \
--link redis:redis \
ttthzy/dinp_router

# Scribe容器

docker run -d --name scribe -p 1463:1463 \
-v $HOME/dinp/data/scribe:/tmp/scribetest \
ttthzy/dinp_scribe