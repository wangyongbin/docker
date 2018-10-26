mkdir -p /home/sa/work/docker/mnt/harbor/log/docker/
mkdir -p /home/sa/work/docker/mnt/harbor/data/registry
mkdir -p /home/sa/work/docker/mnt/harbor/data/database
mkdir -p /home/sa/work/docker/mnt/harbor/data/config/
mkdir -p /home/sa/work/docker/mnt/harbor/data/secretkey
mkdir -p /home/sa/work/docker/mnt/harbor/data/
mkdir -p /home/sa/work/docker/mnt/harbor/data/secretkey
mkdir -p /home/sa/work/docker/mnt/harbor/data/ca_download/
mkdir -p /home/sa/work/docker/mnt/harbor/data/psc/
mkdir -p /home/sa/work/docker/mnt/harbor/data/job_logs
mkdir -p /home/sa/work/docker/mnt/harbor/data/redis


docker run -d --name registry \
-v /home/sa/work/docker/mnt/harbor/data/registry:/storage:z \
-v /home/sa/work/docker/registry/harbor-1.5.3/make/common/config/registry/:/etc/registry/:z \
--network harbor \
--network-alias registry \
-e GODEBUG=netdns=cgo \
vmware/registry-photon:v2.6.2-v1.5.2 serve /etc/registry/config.yml


docker run -d --name harbor-db \
-v /home/sa/work/docker/mnt/harbor/data/database:/var/lib/mysql:z \
--env-file /home/sa/work/docker/registry/harbor-1.5.3/make/common/config/db/env \
--network harbor \
--network-alias mysql \
vmware/harbor-db:v1.5.2


docker run -d --name harbor-adminserver \
-v /home/sa/work/docker/mnt/harbor/data/config/:/etc/adminserver/config/:z \
-v /data/secretkey:/etc/adminserver/key:z \
-v /home/sa/work/docker/mnt/harbor/data/:/data/:z \
--env-file /home/sa/work/docker/registry/harbor-1.5.3/make/common/config/adminserver/env \
--network harbor \
--network-alias adminserver \
vmware/harbor-adminserver:v1.5.2




--
docker run -d --name redis \
-v /home/sa/work/docker/mnt/harbor/data/redis:/data \
--network harbor \
--network-alias redis \
vmware/redis-photon:v1.5.2


docker run -d --name harbor-ui \
-v /home/sa/work/docker/registry/harbor-1.5.3/make/common/config/ui/app.conf:/etc/ui/app.conf:z \
-v /home/sa/work/docker/registry/harbor-1.5.3/make/common/config/ui/private_key.pem:/etc/ui/private_key.pem:z \
-v /home/sa/work/docker/registry/harbor-1.5.3/make/common/config/ui/certificates/:/etc/ui/certificates/:z \
-v /data/secretkey:/etc/ui/key:z \
-v /home/sa/work/docker/mnt/harbor/data/ca_download/:/etc/ui/ca/:z \
-v /home/sa/work/docker/mnt/harbor/data/psc/:/etc/ui/token/:z \
--env-file /home/sa/work/docker/registry/harbor-1.5.3/make/common/config/ui/env \
--network harbor \
--network-alias ui \
vmware/harbor-ui:v1.5.2


docker run -d --name nginx -p 28080:80 \
-v /home/sa/work/docker/registry/harbor-1.5.3/make/common/config/nginx:/etc/nginx:z \
--network harbor \
--network-alias proxy \
vmware/nginx-photon:v1.5.2