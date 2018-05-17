docker volume create vol_mongo

docker run --restart=always -d --name dev-mongo \
-v vol_mongo:/data/db \
mongo
