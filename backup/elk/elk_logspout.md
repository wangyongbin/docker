# logspout + elk 容器日志自动发收集 

elasticsearch：文档数据库，用来存储收集到的日志。数据库是有状态的，需要使用宿主机的文件系统存储数据，因此设置了"node.hostname == manager"的约束条件，只能部署在manager节点上，不能迁移到其它node上，避免数据丢失，只部署一个实例。

logstash：从所有的数据源收集数据并对数据做预处理，然后再提交给elasticsearch，只部署一个实例，无状态，对node无要求。

kibana：UI界面，负责展示数据，只部署一个实例，无状态，对node无要求。

logspout: 是在用于收集Docker容器日志的工具。它连接到主机上的所有容器，然后将其路由到你想让让它去的地方。它也有一个可扩展的模块系统。现在它仅捕获STDOUT和STDERR。

### elk 容器栈

使用docker hub 官方镜像

##### elasticsearch
```aidl

docker run --name logs_es -d -p 9200:9200 \
-v /home/sa/work/docker/mnt/esdata:/usr/share/elasticsearch/data \
elasticsearch:5.6

```
[http://127.0.0.1:9200/_cat/indices?v](http://127.0.0.1:9200/_cat/indices?v**) 

*这里发生一个启动错误*

 > [1]: max virtual memory areas vm.max_map_count [65530] is too low, increase to at least [262144]

查看虚拟内存区域的大小

```aidl

sysctl vm.max_map_count 

```

修改虚拟内存区域的大小为 262144 即可

临时起效
```aidl

sysctl vm.max_map_count 
vm.max_map_count = 65530

```

永久起效

```aidl

sudo vim /etc/sysctl.conf 
vm.max_map_count=262144


```
 

##### logstash
```aidl

docker run --name logs_logstash -d -p 5044:5044 -p 5044:5044/udp \
logstash:5.6 -e 'input { udp{ port  => 5044 codec => json } } filter { if [docker][image] =~ /logstash/ { drop { } } } output { elasticsearch { hosts => ["192.168.1.171:9200"] } stdout { codec => rubydebug } }'

```

##### kibana
```aidl

docker run --name logs_kibana -d -p 5601:5601 \
-e ELASTICSEARCH_URL=http://192.168.1.171:9200 \
kibana:5.6

```

### logspout

```aidl

docker run --name logs_logspout -d \
-v /var/run/docker.sock:/var/run/docker.sock \
-e ROUTE_URIS='logstash+udp://192.168.1.171:5044' \
bekt/logspout-logstash

```

### 测试

启动测试容器，然后访问kibana，即可查看收集到的容器日志

```aidl

docker run --rm -d --name test_busybox -d busybox sh -c 'while true; do echo "This is a log message from container busybox!"; sleep 10; done;'

```


### 参考
* [Docker 日志的 10 大陷阱](http://baijiahao.baidu.com/s?id=1604700946037594427&wfr=spider&for=pc)
* [Docker swarm集群日志管理ELK实战](https://blog.csdn.net/dkfajsldfsdfsd/article/details/79987753)
* [Docker日志自动化: ElasticSearch、Logstash、Kibana以及Logspout](https://blog.csdn.net/fenglailea/article/details/53584674)
