#!/bin/sh
#
# 命令:
#   sudo sh nginx-agent.sh [CONSUL_IP] 
# 参数解释： 
#  CONSUl_IP  consul 地址
#
#变量
CONSUL_IP=${1}
container_name=nginx_agent
##
echo "--- Download coss-nginx:1.0 Image ---"
#docker pull coss-nginx:1.0

##
docker inspect --format '{{.Name}}' ${container_name}
if [ $? -eq 0 ]; then 
	docker stop ${container_name} && docker rm -fv ${container_name}
fi
echo "--- Nginx Auto Load Balancer Install ---"
docker run -d \
    --restart=always \
    --name ${container_name} \
    -p 80:80 \
    -e 'CONSUL_URL=${CONSUL_IP}' \
    coss-nginx:1.0
if [ $? -eq 0 ];then
	echo "--- Nginx Auto LoadBalancer Install Success!!! ---"	
fi
