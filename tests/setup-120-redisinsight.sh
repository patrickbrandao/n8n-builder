#!/bin/bash

# Variaveis
    NAME=redis-insight;
    LOCAL=$NAME.intranet.br;
    FQDN="insight.$(hostname -f)";

    # Login e senha
    # - requer comando htpasswd
    which htpasswd || apt-get install -y apache2-utils
    # Definir:
    AUTH_USER="admin";
    AUTH_PASS="tulipa";
    AUTH_LOGIN=$(htpasswd -nbm "$AUTH_USER" "$AUTH_PASS");

# Imagem:
    IMAGE="redis/redisinsight:latest";
    docker pull $IMAGE;

# Pasta de persistencia
    DATADIR=/storage/redis-insight;
    mkdir  -p $DATADIR;
    mkdir  -p $DATADIR/logs;

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
        --ip=10.117.120.1 \
        --ip6=2001:db8:10:117::120:1 \
        --mac-address "02:cd:01:20:00:01" \
        \
        -p 5540:5540 \
        \
        -v $DATADIR:/data \
        \
        --label "traefik.enable=true" \
        --label "traefik.http.routers.$NAME.rule=Host(\`$FQDN\`)" \
        --label "traefik.http.routers.$NAME.entrypoints=websecure" \
        --label "traefik.http.routers.$NAME.tls=true" \
        --label "traefik.http.routers.$NAME.tls.certresolver=letsencrypt" \
        --label "traefik.http.services.$NAME.loadbalancer.server.port=5540" \
        \
        --label "traefik.http.routers.$NAME.middlewares=$NAME-auth" \
        --label "traefik.http.middlewares.$NAME-auth.basicauth.users=$AUTH_LOGIN" \
        \
        $IMAGE;

    echo;
    echo " Acesso: https://$FQDN";
    echo;

exit 0;

# Analise
    docker logs redis-insight;






docker run -d --name redis-stack -p 6379:6379 -p 8001:8001 -e REDIS_ARGS="--requirepass mypassword" redis/redis-stack:latest
docker run -d --name redisinsight -p 5540:5540 -v redisinsight:/data -e RI_ENCRYPTION_KEY="your-secret-key" redis/redisinsight:latest




