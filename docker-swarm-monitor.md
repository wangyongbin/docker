# docker swarm mode 性能监控平台


#1，创建网络
docker network create --driver overlay vlan_monitor

#2，创建influxdb 数据存储
docker volume create vol_influxdb
docker service create --network vlan_monitor \
-p 8083:8083 -p 8086:8086 \
--mount source=vol_influxdb,type=volume,target=/var/lib/influxdb \
--name=influxdb \
--constraint 'node.hostname==work1' \
tutum/influxdb:0.13

#3，创建用户和数据库

CREATE USER "cadvisor" WITH PASSWORD '123456' WITH ALL PRIVILEGES
CREATE DATABASE "cadvisor"

#4，创建cadvisor 数据采集
docker service create --network vlan_monitor \
--name cadvisor \
-p 8080:8080 \
--mode global \
--mount source=/var/run,type=bind,target=/var/run,readonly=false \
--mount source=/,type=bind,target=/rootfs,readonly=true \
--mount source=/sys,type=bind,target=/sys,readonly=true \
--mount source=/var/lib/docker,type=bind,target=/var/lib/docker,readonly=true \
google/cadvisor:v0.27.4 -storage_driver=influxdb -storage_driver_host=influxdb:8086 -storage_driver_db=cadvisor


select * from cpu_usage_system limit 100
#5，创建Grafana 数据展示
docker volume create vol_grafana
docker service create --network vlan_monitor \
-p 3000:3000 \
--name grafana \
--mount type=volume,src=vol_grafana,dst=/var/lib/grafana \
grafana/grafana:5.2.0