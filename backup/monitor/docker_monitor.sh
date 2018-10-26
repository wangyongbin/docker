## create volume

docker volume create vol_prometheus
docker volume create vol_grafana

docker run --name monitor_cadvisor -d -p 8080:8080 \
--volume=/:/rootfs:ro \
--volume=/var/run:/var/run:rw \
--volume=/sys:/sys:ro \
--volume=/var/lib/docker/:/var/lib/docker:ro \
--detach=true \
google/cadvisor:v0.28.5

docker run --name monitor_node_exporter -d -p 9100:9100 \
-v "/proc:/host/proc" \
-v "/sys:/host/sys" \
-v "/:/rootfs" \
prom/node-exporter:v0.16.0 \
--path.procfs /host/proc \
--path.sysfs /host/sys \
--collector.filesystem.ignored-mount-points "^/(sys|proc|dev|host|etc)($|/)"

docker run --name monitor_prometheus -d -p 9090:9090 \
-v ~/work/docker/mnt/prometheus/prometheus.yml:/etc/prometheus/prometheus.yml \
-v vol_prometheus:/prometheus \
prom/prometheus:v2.3.2

docker run --name monitor_grafana -d -p 3000:3000 \
-e "GF_SERVER_ROOT_URL=http://grafana.server.name" \
-e "GF_SECURITY_ADMIN_PASSWORD=admin" \
-v vol_grafana:/var/lib/grafana \
grafana/grafana:5.2.2