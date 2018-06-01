#!/bin/bash

###https://humpback.github.io/humpback/#/zh-cn/

# step 1 install registry

mkdir -p $HOME/humpback/registry
mkdir -p $HOME/humpback/web/dbFiles

# init registry

docker run -d --name registry -p 5000:5000 --restart=always \
-v $HOME/humpback/registry/:/var/lib/registry/ \
registry:2.5.1

# init humpback-web

docker run -d --name humpback-web --net=host --restart=always \
-e HUMPBACK_LISTEN_PORT=8012 \
-v $HOME/humpback/web/dbFiles:/humpback-web/dbFiles \
humpbacks/humpback-web:1.3.0

# init humpback
docker run -d --name=humpback-agent --net=host --restart=always \
-e DOCKER_API_VERSION=v1.21 \
-e DOCKER_CLUSTER_ENABLED=false \
-v /var/run/:/var/run/:rw \
humpbacks/humpback-agent:1.3.0