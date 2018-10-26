
# log-pilot + elk 收集容器日志

elasticsearch：文档数据库，用来存储收集到的日志。数据库是有状态的，需要使用宿主机的文件系统存储数据，因此设置了"node.hostname == manager"的约束条件，只能部署在manager节点上，不能迁移到其它node上，避免数据丢失，只部署一个实例。

logstash：从所有的数据源收集数据并对数据做预处理，然后再提交给elasticsearch，只部署一个实例，无状态，对node无要求。

kibana：UI界面，负责展示数据，只部署一个实例，无状态，对node无要求。

log-pilot 具有如下特性：

* 一个单独的 log 进程收集机器上所有容器的日志。不需要为每个容器启动一个 log 进程。
* 支持文件日志和 stdout。docker log dirver 亦或 logspout 只能处理 stdout，log-pilot 不仅支持收集 stdout 日志，还可以收集文件日志。
* 声明式配置。当您的容器有日志要收集，只要通过 label 声明要收集的日志文件的路径，无需改动其他任何配置，log-pilot 就会自动收集新容器的日志。
* 支持多种日志存储方式。无论是强大的阿里云日志服务，还是比较流行的 elasticsearch 组合，甚至是 graylog，log-pilot 都能把日志投递到正确的地点。
* 开源。log-pilot 完全开源，您可以从 这里 下载代码。如果现有的功能不能满足您的需要，欢迎提 issue。

### elk 容器栈

使用docker hub 官方镜像

##### elasticsearch
```aidl

docker run --name logs_es -d -p 9200:9200 \
-v /home/sa/work/docker/mnt/esdata:/usr/share/elasticsearch/data \
elasticsearch:5.6

```
[http://127.0.0.1:9200/_cat/indices?v](http://127.0.0.1:9200/_cat/indices?v**) 


##### logstash
```aidl

docker run --name logs_logstash -d -p 5044:5044 -p 5000:5000 \
logstash:5.6 -e 'input { beats { port  => 5044 type => beats } tcp { port => 5000 type => syslog } } filter { if [docker][image] =~ /logstash/ { drop { } } } output { elasticsearch { hosts => ["192.168.1.171:9200"] } stdout { codec => rubydebug } }'

```

##### kibana
```aidl

docker run --name logs_kibana -d -p 5601:5601 \
-e ELASTICSEARCH_URL=http://192.168.1.171:9200 \
kibana:5.6

```

### log-pilot

使用阿里云提供的镜像 registry.cn-hangzhou.aliyuncs.com/acs-sample/log-pilot:latest

##### 收集日志输出到 elasticsearch
```aidl

docker run -d --name logs_logpilot \
-v /var/run/docker.sock:/var/run/docker.sock \
-v /:/host:ro \
-e PILOT_TYPE=filebeat \
-e LOGGING_OUTPUT=elasticsearch \
-e ELASTICSEARCH_HOST=192.168.1.171 \
-e ELASTICSEARCH_PORT=9200 \
registry.cn-hangzhou.aliyuncs.com/acs-sample/log-pilot:latest

```

##### 收集日志输出到 logstash

```aidl

docker run -d --restart=always --name logs_logpilot \
-v /var/run/docker.sock:/var/run/docker.sock \
-v /:/host:ro \
-e PILOT_TYPE=filebeat \
-e LOGGING_OUTPUT=logstash \
-e LOGSTASH_HOST=192.168.1.171 \
-e LOGSTASH_PORT=5044 \
registry.cn-hangzhou.aliyuncs.com/acs-sample/log-pilot:latest

```

### 测试

打开kibana，这时候你应该还看不到新日志，需要先创建index。log-pilot会把日志写到elasticsearch特定的index下，规则如下

1. 如果应用上使用了标签aliyun.logs.tags，并且tags里包含target，使用target作为elasticsearch里的index，否则
2. 使用标签aliyun.logs.XXX里的XXX作为index

**注意了这里的规则适用于日志直接输出到elasticsearch**

```aidl

docker run --rm -it  \
--label aliyun.logs.busybox=stdout \
busybox sh -c 'while true; do echo "This is a log message from container busybox!"; sleep 10; done;'

```

or

```aidl

docker run --rm -it -p 10080:8080 \
--label aliyun.logs.tomcat=stdout \
tomcat:7.0-jre8

```

这时打卡kibana新建index为logstash-*索引

![image](http://172.16.1.61/wangyongbin/docker/raw/master/elk/images/0cdb088ab03fcbbf8e08d72665e3543f360783e6.png)

创建好index就可以查看日志了。

![image](http://172.16.1.61/wangyongbin/docker/raw/master/elk/images/722c2263b7d74118400909ad9506cbd6361c0555.png)


### 注意事项

1. 收集docker swarm 创建的服务需要添加 --container-label aliyun.logs.XXX=stdout，而不是 --label aliyun.logs.XXX=stdout
2. log-pilot 在docker-ce-17.09.0.ce版本中以容器的方式运行需要 --privileged，以服务的方式运行则不行服务不支持--privileged;  
在docker-ce-18.03.0.ce则可以以服务的方式运行。
3. docker swarm 里部署请参考docker_logpilot_swarm.sh文件


### 参考
* [容器服务中使用ELK](https://yq.aliyun.com/articles/60059?spm=a2c4e.11153940.blogcont69382.20.65b278fcDS9S79)
* [Docker 日志收集新方案：log-pilot](https://helpcdn.aliyun.com/document_detail/50441.html)
* [Docker 日志收集新方案：log-pilot](https://yq.aliyun.com/articles/69382)