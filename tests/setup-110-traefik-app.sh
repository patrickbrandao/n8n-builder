#!/bin/bash

# Variaveis
    NAME=traefik-app;
    LOCAL=$NAME.intranet.br;
    EMAIL="root@intranet.br";
    [ -f /etc/email ] && EMAIL=$(head -1 /etc/email);

# Imagem
    IMAGE=traefik:latest;
    docker pull $IMAGE;

# Diretorio de dados persistentes
    DATADIR=/storage/traefik-app;
    mkdir -p $DATADIR/letsencrypt;
    mkdir -p $DATADIR/logs;
    mkdir -p $DATADIR/config;

# Renovar/rodar:
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
        --ip=10.117.255.253 \
        --ip6=2001:db8:10:117::255:253 \
        --mac-address "02:cd:02:55:02:53" \
        \
        -p 80:80 \
        -p 443:443 \
        \
        -v /var/run/docker.sock:/var/run/docker.sock:ro \
        -v $DATADIR/letsencrypt:/etc/letsencrypt \
        -v $DATADIR/config:/etc/traefik \
        -v $DATADIR/logs:/logs \
        \
        $IMAGE \
            \
            --global.checkNewVersion=false \
            --global.sendAnonymousUsage=false \
            \
            --api.insecure=true \
            \
            --log.level=INFO \
            --log.filePath=/logs/error.log \
            \
            --accessLog.filePath=/logs/access.log \
            \
            --entrypoints.web.address=:80 \
            --entrypoints.web.http.redirections.entryPoint.to=websecure \
            --entrypoints.web.http.redirections.entryPoint.scheme=https \
            --entrypoints.web.http.redirections.entryPoint.permanent=true \
            --entrypoints.websecure.address=:443 \
            \
            --providers.docker=true \
            --providers.file.directory=/etc/traefik \
            \
            --certificatesresolvers.letsencrypt.acme.email=$EMAIL \
            --certificatesresolvers.letsencrypt.acme.storage=/etc/letsencrypt/acme.json \
            --certificatesresolvers.letsencrypt.acme.httpchallenge.entrypoint=web;


exit 0;

