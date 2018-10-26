# filebeat + elk

elasticsearch：文档数据库，用来存储收集到的日志。数据库是有状态的，需要使用宿主机的文件系统存储数据，因此设置了"node.hostname == manager"的约束条件，只能部署在manager节点上，不能迁移到其它node上，避免数据丢失，只部署一个实例。

logstash：从所有的数据源收集数据并对数据做预处理，然后再提交给elasticsearch，只部署一个实例，无状态，对node无要求。

kibana：UI界面，负责展示数据，只部署一个实例，无状态，对node无要求。

filebeat: 容器收集利器，如有如下功能

* 在任何环境下，应用程序都有停机的可能性。 Filebeat 读取并转发日志行，如果中断，则会记住所有事件恢复联机状态时所在位置。
* Filebeat带有内部模块（auditd，Apache，Nginx，System和MySQL），可通过一个指定命令来简化通用日志格式的收集，解析和可视化。
* FileBeat 不会让你的管道超负荷。FileBeat 如果是向 Logstash 传输数据，当 Logstash 忙于处理数据，会通知 FileBeat 放慢读取速度。一旦拥塞得到解决，FileBeat 将恢复到原来的速度并继续传播。

### elk

````aidl

docker run -itd --privileged --name elk -p 5601:5601 -p 9200:9200 -p 5044:5044  \
-e ES_HEAP_SIZE="2g" \
-e LS_HEAP_SIZE="1g" \
-e MAX_MAP_COUNT=262144  \
sebp/elk

````

* 5601 Kibana web 访问端口).
* 9200 (Elasticsearch JSON 访问端口).
* 5044 (Logstash Beats 访问端口, 接收来自Filebeat 日志，具体请参看Filebeat日志转发).


*这里发生一个启动错误*

 >> [1]: max virtual memory areas vm.max_map_count [65530] is too low, increase to at least [262144]

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

sysctl -p

```

### 安装 filebeat 

```aidl

curl -L -O https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-6.3.1-amd64.deb
sudo dpkg -i filebeat-6.3.1-amd64.deb

```

### 配置 filebeat.yml

Filebeat 的配置文件为 /etc/filebeat/filebeat.yml，我们需要告诉 Filebeat 两件事：

1. 监控哪些日志文件？
2. 将日志发送到哪里？

filebeat.yml 内大致如下
```aidl

filebeat.inputs:
- type: log
  enabled: true
  paths:
    - /var/log/*.log
    - /var/lib/docker/containers/*/*.log

setup.template.settings:
  index.number_of_shards: 3

output.elasticsearch:
  hosts: ["127.0.0.1:9200"]

```

在 paths 中我们配置了两条路径：

* /var/lib/docker/containers/*/*.log 是所有容器的日志文件。
* /var/log/syslog 是 Host 操作系统的 syslog。

接下来告诉 Filebeat 将这些日志发送给 ELK。

Filebeat 可以将日志发送给 Elasticsearch 进行索引和保存；也可以先发送给 Logstash 进行分析和过滤，然后由 Logstash 转发给 Elasticsearch。

为了不引入过多的复杂性，我们这里将日志直接发送给 Elasticsearch。

### 启动 filebeat 服务

```aidl

systemctl start filebeat.service

```
Filebeat 服务启动后，正常情况下会将监控的日志发送给 Elasticsearch。刷新 Elasticsearch 的 JSON 接口[http://127.0.0.1:9200/_search?pretty](http://127.0.0.1:9200/_search?pretty)进行确认。

### 管理日志

访问kibana[http://127.0.0.1:5601](http://127.0.0.1:5601)进行日志管理，在kibana新建 filebeat-* 索引，然后启动测试容器。

```aidl

docker run --rm -d busybox sh -c 'while true; do echo "This is a log message from container busybox!"; sleep 10; done;'

```

再查看kibana页面，结果如下：

![image](http://172.16.1.61/wangyongbin/docker/raw/master/elk/images/upload-ueditor-image-20171105-1509871988385094430.png)

### 参考
* [初探 ELK ](https://www.cnblogs.com/CloudMan6/p/7770916.html)
* [ELK 完整部署和使用](https://www.cnblogs.com/CloudMan6/p/7787870.html)
* [elk](http://elk-docker.readthedocs.io/)
* [Elastic 技术栈之 Filebeat](https://www.cnblogs.com/jingmoxukong/p/8185321.html)
