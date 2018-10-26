
docker build -t nginx-docker:v1.0 .

docker run --rm -d --name docker-ce-version -p 18080:80 nginx-docker:v1.0

http://docker.ib2000.net:18080/docker/18.03.sh

http://docker.ib2000.net:18080/docker/index

docker-machine create -d virtualbox \
--engine-install-url=http://docker.ib2000.net:18080/docker/index \
node1


docker-machine create --driver generic \
--engine-install-url=http://docker.ib2000.net:18080/docker/index \
--generic-ip-address=192.168.99.103 \
node3