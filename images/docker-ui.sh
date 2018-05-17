docker volume create vol_portainer_data

docker run -d --restart=always \
-p 9000:9000 \
-v /var/run/docker.sock:/var/run/docker.sock \
-v vol_portainer_data:/data \
portainer/portainer
