docker volume create vol_mongo
docker volume create vol_mongo_configdb

docker run --restart=always -d --name dev-mongo \
-v vol_mongo:/data/db \
-v vol_mongo_configdb:/data/configdb \
-p 27017:27017 \
mongo:3.7
