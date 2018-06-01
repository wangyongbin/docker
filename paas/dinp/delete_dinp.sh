###https://leo108.com/pid-2109/

# delete container

funcation del(){
    docker rm -fv $1;
}

del jenkins;
del registry;
del memcached;
del redis;
del mysql;
del uic;
del dinp_builder;
del dinp_server;
del dinp_dash;
del dinp_agent;
del dinp_router;
del scribe;