docker run -d --restart=always --name dev-redis \
-p 6379:6379 \
--mount type=volume,src=vol_redis,dst=/data \
redis:4.0-alpine
