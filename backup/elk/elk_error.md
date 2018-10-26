#部署 xxx + elk错误信息


#### log-pilot + elk 

1. umount: can't unmount /host/home/docker/docker_data/containers/fc86aa1b1a200324d51bbb1a057bd046be9510af7309b5e09f63eb87a8257cae/shm: Operation not permitted

   解决: 容器加 --privileged
