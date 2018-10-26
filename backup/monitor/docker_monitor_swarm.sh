## create volume

docker volume create vol_prometheus
docker volume create vol_grafana

docker network create --driver overlay vlan_daemon

docker service create --name monitor_cadvisor --mode=global \
--publish 8080:8080 \
--network vlan_daemon \
--mount type=bind,src=/var/run,dst=/var/run,readonly=false \
--mount type=bind,src=/,dst=/rootfs,readonly=true \
--mount type=bind,src=/sys,dst=/sys,readonly=true \
--mount type=bind,src=/var/lib/docker,dst=/var/lib/docker,readonly=true  \
google/cadvisor:v0.28.5

docker service create --name monitor_node_exporter --mode=global \
--publish 9100:9100 \
--network vlan_daemon \
--mount type=bind,src=/proc,dst=/host/proc,readonly=true \
--mount type=bind,src=/sys/,dst=/host/sys,readonly=true \
--mount type=bind,src=/,dst=/rootfs,readonly=true \
prom/node-exporter:v0.16.0 \
--path.procfs /host/proc \
--path.sysfs /host/sys \
--collector.filesystem.ignored-mount-points "^/(sys|proc|dev|host|etc)($|/)"


docker service create --name monitor_prometheus \
--publish 9090:9090 \
--network vlan_daemon \
--mount type=bind,src=$HOME/work/docker/mnt/prometheus/swarm/prometheus.yml,dst=/etc/prometheus/prometheus.yml \
--mount type=volume,src=vol_prometheus,dst=/prometheus \
prom/prometheus:v2.3.2

docker service create --name monitor_grafana \
--publish 3000:3000 \
--network vlan_daemon \
--env "GF_SECURITY_ADMIN_PASSWORD=admin" \
--mount type=volume,src=vol_grafana,dst=/var/lib/grafana \
grafana/grafana:5.2.2