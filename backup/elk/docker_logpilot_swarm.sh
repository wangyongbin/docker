
docker volume create vol_esdata

docker service create --name logses --publish 9200:9200 \
--network vlan_daemon \
--mount type=volume,src=vol_esdata,dst=/usr/share/elasticsearch/data \
elasticsearch:5.6

docker service create --name logslogstash --publish 5044:5044 --publish 5000:5000 \
--network vlan_daemon \
logstash:5.6 -e 'input { beats { port  => 5044 type => beats } tcp { port => 5000 type => syslog } } filter { if [docker][image] =~ /logstash/ { drop { } } } output { elasticsearch { hosts => ["logses:9200"] } stdout { codec => rubydebug } }'

docker service create --name logskibana --publish 5601:5601 \
--network vlan_daemon \
-e ELASTICSEARCH_URL=http://logses:9200 \
kibana:5.6


#### 18.03-ce 可以使用服务的方式部署log-pilot
#### logstash
## service
docker service create --name logslogpilot \
--mount type=bind,src=/var/run/docker.sock,dst=/var/run/docker.sock \
--mount type=bind,src=/,dst=/host,readonly=true \
-e PILOT_TYPE=filebeat \
-e LOGGING_OUTPUT=logstash \
-e LOGSTASH_HOST=logslogstash \
-e LOGSTASH_PORT=5044 \
registry.cn-hangzhou.aliyuncs.com/acs-sample/log-pilot:latest

## container
docker run -d --restart=always --name logslogpilot \
-v /var/run/docker.sock:/var/run/docker.sock \
-v /:/host:ro \
-e PILOT_TYPE=filebeat \
-e LOGGING_OUTPUT=elasticsearch \
-e ELASTICSEARCH_HOST=192.168.1.171 \
-e ELASTICSEARCH_PORT=9200 \
registry.cn-hangzhou.aliyuncs.com/acs-sample/log-pilot:latest


#### 日志输出到elasticsearch
## service
docker service create --name logslogpilot \
--network vlan_daemon \
--mount type=bind,src=/var/run/docker.sock,dst=/var/run/docker.sock \
--mount type=bind,src=/,dst=/host,readonly=true \
-e PILOT_TYPE=filebeat \
-e LOGGING_OUTPUT=elasticsearch \
-e ELASTICSEARCH_HOST=logses \
-e ELASTICSEARCH_PORT=9200 \
registry.cn-hangzhou.aliyuncs.com/acs-sample/log-pilot:latest

## container
docker run -d --restart=always --name logslogpilot \
-v /var/run/docker.sock:/var/run/docker.sock \
-v /:/host:ro \
-e PILOT_TYPE=filebeat \
-e LOGGING_OUTPUT=elasticsearch \
-e ELASTICSEARCH_HOST=192.168.1.171 \
-e ELASTICSEARCH_PORT=9200 \
registry.cn-hangzhou.aliyuncs.com/acs-sample/log-pilot:latest