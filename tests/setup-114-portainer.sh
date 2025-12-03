#!/bin/bash

# Variaveis
    NAME=portainer;
    DOMAIN="$(hostname -f)";
    FQDN="$NAME.$DOMAIN";
    LOCAL=$NAME.intranet.br;

# Imagem:
    IMAGE=portainer/portainer-ce:latest;
    docker pull $IMAGE;

# Pasta de persistencia
    DATADIR=/storage/portainer;
    mkdir  -p $DATADIR;

# Renovar/rodar
    docker rm -f $NAME 2>/dev/null
    docker pull $IMAGE;
    docker run \
        -d --restart=always \
        --name $NAME -h $LOCAL \
        --tmpfs /run:rw,noexec,nosuid,size=2m \
        --tmpfs /tmp:rw,noexec,nosuid,size=2m \
        --read-only \
        --cpus="8.0" --memory=4g --memory-swap=4g \
        \
        --network network_public \
        --ip=10.117.255.251 \
        --ip6=2001:db8:10:117::255:251 \
        --mac-address "02:cd:02:55:02:51" \
        \
        -p 8000:8000 \
        -p 9443:9443 \
        \
        -v /var/run/docker.sock:/var/run/docker.sock \
        --mount \
            type=bind,source=$DATADIR,destination=/data,readonly=false \
        \
        --label "traefik.enable=true" \
        --label "traefik.http.routers.portainer.rule=Host(\`$FQDN\`)" \
        --label "traefik.http.routers.portainer.entrypoints=websecure" \
        --label "traefik.http.routers.portainer.tls=true" \
        --label "traefik.http.routers.portainer.tls.certresolver=letsencrypt" \
        --label "traefik.http.services.portainer.loadbalancer.server.port=9000" \
        \
        $IMAGE;

exit 0


