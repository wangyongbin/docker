## 监控数据收集 
cAdvisor google开发的的容器监控工具，可以监控cpu、内存、网络、文件系统等资源使用的情况。


## Prometheus 监控系统
Prometheus 提供了监控数据的收集、存储、处理、可视化、和告警一套完整的解决方案。

Prometheus Server
	Prometheus Server 负责从 Exporter 拉取和存储监控数据，并提供一套灵活的查询语言（PromQL）供用户使用。
	
Exporter
	Exporter 负责收集目标对象（host, container…）的性能数据，并通过 HTTP 接口供 Prometheus Server 获取。
	
可视化组件
	监控数据的可视化展现对于监控方案至关重要。以前 Prometheus 自己开发了一套工具，不过后来废弃了，因为开源社区出现了更为优秀的产品 Grafana。Grafana 能够与 Prometheus 无缝集成，提供完美的数据展示能力。
	
Alertmanager
  	用户可以定义基于监控数据的告警规则，规则会触发告警。一旦 Alermanager 收到告警，会通过预定义的方式发出告警通知。支持的方式包括 Email、PagerDuty、Webhook 等.

--
Node Exporter，负责收集 host 硬件和操作系统数据。它将以容器方式运行在所有 host 上。

docker run --name monitor_node_exporter -d -p 9100:9100 \
-v "/proc:/host/proc" \
-v "/sys:/host/sys" \
-v "/:/rootfs" \
prom/node-exporter:v0.16.0 \
--path.procfs /host/proc \
--path.sysfs /host/sys \
--collector.filesystem.ignored-mount-points "^/(sys|proc|dev|host|etc)($|/)"

http://192.168.1.171:9100/metrics 

--
cAdvisor，负责收集容器数据。它将以容器方式运行在所有 host 上。

docker run --name monitor_cadvisor -d -p 8080:8080 \
--volume=/:/rootfs:ro \
--volume=/var/run:/var/run:rw \
--volume=/sys:/sys:ro \
--volume=/var/lib/docker/:/var/lib/docker:ro \
--detach=true \
google/cadvisor:v0.28.5

--
promethus server

docker run --name monitor_prometheus -d -p 9090:9090 \
-v ~/work/docker/mnt/prometheus/prometheus.yml:/etc/prometheus/prometheus.yml \
-v vol_prometheus:/prometheus \
prom/prometheus:v2.3.2


http://192.168.1.171:9090

--
grafana 展示

docker run --name monitor_grafana -d -p 3000:3000 \
-e "GF_SERVER_ROOT_URL=http://grafana.server.name" \
-e "GF_SECURITY_ADMIN_PASSWORD=admin" \
-v vol_grafana:/var/lib/grafana \
grafana/grafana:5.2.2

[Prometheus 监听模板](https://grafana.com/dashboards/893)
-- 
grafana 数据持久化

默认数据库 sqlite3

修改文件 /etc/grafana/grafana.ini 更改默认数据库