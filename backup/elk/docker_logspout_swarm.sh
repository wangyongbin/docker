## create volume

docker network create --driver overlay vlan_daemon

docker service create --name logses \
--publish 9200:9200 \
--network vlan_daemon \
--mount type=bind,src=$HOME/work/docker/mnt/esdata,dst=/usr/share/elasticsearch/data \
elasticsearch:5.6

docker service create --name logslogstash \
--publish 15000:15000 \
--publish 15000:15000/udp \
--network vlan_daemon \
logstash:5.6 -e 'input { udp{ port  => 15000 codec => json } } filter { if [docker][image] =~ /logstash/ { drop { } } } output { elasticsearch { hosts => ["logses:9200"] } stdout { codec => rubydebug } }'

docker service create --name logslogspout \
--network vlan_daemon \
--mount type=bind,src=/var/run/docker.sock,dst=/var/run/docker.sock \
-e ROUTE_URIS='logstash+udp://logslogstash:15000' \
bekt/logspout-logstash

docker service create --name logskibana \
--publish 5601:5601 \
--network vlan_daemon \
-e ELASTICSEARCH_URL=http://logses:9200 \
kibana:5.6

#https://www.jianshu.com/p/930917d05b63
