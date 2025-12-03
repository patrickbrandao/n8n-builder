#!/bin/bash

# n8n
#   - single main, single instance, sqlite database
#   - runners: internal

# Funcoes
    _echo_title(){ echo; printf "\033[33;7m > \033[0m\033[32;7m $1 \033[0m\n"; };

# Variaveis
    NAME="n8n-201-single-sqlite";
    LOCAL="$NAME.intranet.br";

# Rede
    NETWORK="network_public";
    N8N_CONTAINER_MAC="02:cd:f2:01:00:01";
    N8N_CONTAINER_IPV4="10.117.201.1";
    N8N_CONTAINER_IPV6="2001:db8:10:117::201:1";

# Imagem - n8n
    N8N_VERSION=${N8N_VERSION:-latest};
    N8N_IMAGE_STD="ghcr.io/n8n-io/n8n:$N8N_VERSION";
    N8N_IMAGE_ARG="$1";
    N8N_IMAGE="${N8N_IMAGE_ARG:-$N8N_IMAGE_STD}"
    echo "$N8N_IMAGE" | egrep -q '/' && docker pull $N8N_IMAGE;


# Volume
    DATADIR=/storage/$NAME;
    mkdir -p $DATADIR;
    chown -R 999:999 $DATADIR;

# Renovar/rodar:
    _echo_title "$0 - Obtendo imagem"
    ( docker stop $NAME; docker rm $NAME; sync && sleep 1; ) 2>/dev/null;

    # Criar
    _echo_title "$0 - Criando e inicializando N8N";
    docker run \
        -d --restart=always \
        --name $NAME -h $LOCAL \
        --user root:root \
        \
        --network $NETWORK \
        --mac-address $N8N_CONTAINER_MAC \
        --ip=$N8N_CONTAINER_IPV4 \
        --ip6=$N8N_CONTAINER_IPV6 \
        \
        -p 10201:5678 \
        \
        -v $DATADIR:/n8n \
        \
        -e N8N_DIAGNOSTICS_ENABLED=false \
        -e N8N_USER_FOLDER=/n8n \
        \
        -e DB_SQLITE_POOL_SIZE=3 \
        -e DB_SQLITE_ENABLE_WAL=true \
        \
        -e N8N_RUNNERS_ENABLED=true \
        -e N8N_RUNNERS_MODE=internal \
        -e N8N_METRICS=true \
        \
        -e N8N_SECURE_COOKIE=false \
        -e N8N_SAMESITE_COOKIE=n8n201 \
        \
        --health-cmd="/bin/sh -c 'wget --spider -q http://localhost:5678/healthz || exit 1'" \
        --health-interval=5s \
        --health-timeout=5s \
        --health-retries=10 \
        \
        $N8N_IMAGE;


exit;

# Definir senha no primeiro setup

    # Esperar
    _echo_title "$0 - Aguardando 10s, esperar o n8n inicializar o SQLITE3";
    sleep 10;

    # Parar N8N
    _echo_title "$0 - Parando N8N";
    docker stop $NAME; sync;
    sleep 1;

    # Definindo usuario
    _echo_title "$0 - Criando usuario";
    /root/n8n-builder/scripts/n8n-sqlite-user-reset.sh "$DATADIR/.n8n/database.sqlite";
    # Definindo via http
    #/root/n8n-builder/scripts/n8n-http-user-setup.sh "http://$N8N_CONTAINER_IPV4:5678";

    # Iniciando n8n
    _echo_title "$0 - Iniciando N8N";
    docker start $NAME;
    echo;


# Acessando:
    # - obter nome do servidor:
    SERVER=$(hostname -f);
    PORT=48022;
    ssh -N root@$SERVER -p $PORT -L 127.0.0.1:10201:10.117.201.1:5678

    # http://127.0.0.1:10201
#        -e N8N_SECURE_COOKIE=false \


# Destruir container e iniciar do zero
    docker rm -f n8n-201-single-sqlite;
    rm  -rf /storage/n8n-201-single-sqlite;
    sh /root/n8n-builder/test-server/setup-201-n8n-sqlite-internal.sh;








