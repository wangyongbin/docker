#!/bin/bash

home_dir=${HOME}

## 创建挂载目录
mkdir -p ${home_dir}/work/docker/mnt/harbor/data/
mkdir -p ${home_dir}/work/docker/mnt/harbor/data/registry
mkdir -p ${home_dir}/work/docker/mnt/harbor/data/database

mkdir -p ${home_dir}/work/docker/mnt/harbor/data/config/
mkdir -p ${home_dir}/work/docker/mnt/harbor/data/ca_download/
mkdir -p ${home_dir}/work/docker/mnt/harbor/data/psc/
mkdir -p ${home_dir}/work/docker/mnt/harbor/data/job_logs
mkdir -p ${home_dir}/work/docker/mnt/harbor/data/redis


cat ${home_dir}/work/docker/harbor/data/secretkey > ${home_dir}/work/docker/mnt/harbor/data/secretkey

# 修改 adminserver/env "EXT_ENDPOINT=http://registry.ib2000.net:50001"
# 修改 registry/config.yml ”realm: http://registry.ib2000.net:50001/service/token"

# 创建网络
docker network create harbor

docker run -d --name registry \
-v ${home_dir}/work/docker/mnt/harbor/data/registry:/storage:z \
-v ${home_dir}/work/docker/harbor/config/registry/:/etc/registry/:z \
--network harbor \
--network-alias registry \
-e GODEBUG=netdns=cgo \
vmware/registry-photon:v2.6.2-v1.5.2 serve /etc/registry/config.yml



docker run -d --name harbor-db \
-v ${home_dir}/work/docker/mnt/harbor/data/database:/var/lib/mysql:z \
--env-file ${home_dir}/work/docker/harbor/config/db/env \
--network harbor \
--network-alias mysql \
vmware/harbor-db:v1.5.2


docker run -d --name harbor-adminserver \
-v ${home_dir}/work/docker/mnt/harbor/data/:/data/:z \
-v ${home_dir}/work/docker/mnt/harbor/data/config/:/etc/adminserver/config/:z \
-v ${home_dir}/work/docker/mnt/harbor/data/secretkey:/etc/adminserver/key:z \
--env-file ${home_dir}/work/docker/harbor/config/adminserver/env \
--network harbor \
--network-alias adminserver \
vmware/harbor-adminserver:v1.5.2


docker run -d --name redis \
-v ${home_dir}/work/docker/mnt/harbor/data/redis:/data \
--network harbor \
--network-alias redis \
vmware/redis-photon:v1.5.2


docker run -d --name harbor-ui \
-v ${home_dir}/work/docker/harbor/config/ui/app.conf:/etc/ui/app.conf:z \
-v ${home_dir}/work/docker/harbor/config/ui/private_key.pem:/etc/ui/private_key.pem:z \
-v ${home_dir}/work/docker/harbor/config/ui/certificates/:/etc/ui/certificates/:z \
-v ${home_dir}/work/docker/mnt/harbor/data/ca_download/:/etc/ui/ca/:z \
-v ${home_dir}/work/docker/mnt/harbor/data/psc/:/etc/ui/token/:z \
-v ${home_dir}/work/docker/mnt/harbor/data/secretkey:/etc/ui/key:z \
--env-file ${home_dir}/work/docker/harbor/config/ui/env \
--network harbor \
--network-alias ui \
vmware/harbor-ui:v1.5.2


docker run -d --name nginx -p 50001:80 \
-v ${home_dir}/work/docker/harbor/config/nginx:/etc/nginx:z \
--network harbor \
--network-alias proxy \
vmware/nginx-photon:v1.5.2