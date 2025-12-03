#!/bin/bash

# Variaveis
    NAME=redis-db;
    LOCAL=$NAME.intranet.br;

# Imagem: https://hub.docker.com/_/redis
    IMAGE=redis:latest;
    docker pull $IMAGE;

# Pasta de persistencia
    DATADIR=/storage/redis-db;
    mkdir  -p $DATADIR;

# Renovar/rodar
    docker rm -f $NAME 2>/dev/null;
    docker run \
        -d --restart=always \
        --name $NAME -h $LOCAL \
        --tmpfs /run:rw,noexec,nosuid,size=2m \
        --tmpfs /tmp:rw,noexec,nosuid,size=2m \
        --read-only \
        --cpus="8.0" --memory=4g --memory-swap=4g \
        \
        --network network_public \
        --ip=10.117.122.1 \
        --ip6=2001:db8:10:117::122:1 \
        --mac-address "02:cd:01:22:00:01" \
        \
        -v $DATADIR:/data \
        \
        --health-cmd="redis-cli ping" \
        --health-interval=1s \
        --health-timeout=3s \
        \
        $IMAGE \
            redis-server \
                --bind '0.0.0.0 ::' \
                --port 6379 \
                --set-proc-title no \
                --tcp-backlog 8192 \
                --tcp-keepalive 30 \
                --timeout 0 \
                \
                --databases 256 \
                \
                --dir /data \
                --save 900 1 \
                --save 300 10 \
                --save 60 10000 \
                \
                --rdbcompression no \
                --rdbchecksum yes \
                --dbfilename redis-db.rdb \
                \
                --appendonly yes \
                --appendfsync everysec \
                --appendfilename "redis-db.aof";


exit 0;

