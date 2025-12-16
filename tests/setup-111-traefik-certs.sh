#!/bin/bash

# Variaveis
    NAME="traefik-certs";
    LOCAL="$NAME.intranet.br";
    FQDN=$(hostname -f);
    DATADIR="/storage/$NAME";
    IMAGE="tmsoftbrasil/traefik-certs:latest";

    #WEBHOOK_URL="https://ws.$FQDN/webhook/cert-watcher";
    WEBHOOK_URL="";

    # pasta onde o traefik salva o acme.json
    TRAEFIK_LETSENCRYPT_DIR="/storage/traefik-app/letsencrypt";

# Diretorio de dados persistentes:
    mkdir -p $DATADIR;
    mkdir -p $DATADIR/logs;
    mkdir -p $DATADIR/certs;

# Imagem construida localmente.
    docker pull $IMAGE;

# Criar e rodar:
    docker rm -f $NAME 2>/dev/null;
    docker run \
        -d --restart=always \
        --name $NAME -h $LOCAL \
        \
        --network network_public \
        --ip=10.117.255.252 \
        --ip6=2001:db8:10:117::255:252 \
        --mac-address "02:cd:02:55:02:52" \
        \
        -e "TCERTS_ACME_JSON=/etc/letsencrypt/acme.json" \
        -e "TCERTS_WEBHOOK_URL=$WEBHOOK_URL" \
        -e "TCERTS_WEBHOOK_BEARER=52169089a52705298a67f2f8d9895c76" \
        \
        -e "TCERTS_SAVEDIR=/data/certs" \
        \
        -v $DATADIR:/data \
        -v $TRAEFIK_LETSENCRYPT_DIR:/etc/letsencrypt \
        \
        --label "traefik.enable=true" \
        --label "traefik.http.routers.$NAME.rule=Host(\`$FQDN\`)" \
        --label "traefik.http.routers.$NAME.entrypoints=websecure" \
        --label "traefik.http.routers.$NAME.tls=true" \
        --label "traefik.http.routers.$NAME.tls.certresolver=letsencrypt" \
        --label "traefik.http.services.$NAME.loadbalancer.server.port=9000" \
        \
        $IMAGE;


exit 0



