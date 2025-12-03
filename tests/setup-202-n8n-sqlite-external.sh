#!/bin/bash

# n8n
#   - single main, single instance, sqlite database
#   - runners: external, criar container runner

# Funcoes
    _echo_title(){ echo; printf "\033[33;7m > \033[0m\033[32;7m $1 \033[0m\n"; };

# Variaveis
    NAME="n8n-202-runner-sqlite";
    LOCAL="$NAME.intranet.br";
    NETWORK="network_public";

    RUNNER="n8n-202-runners";
    RLOCAL="$RUNNER.intranet.br";

# Rede
    N8N_CONTAINER_MAC="02:cd:f2:02:00:01";
    N8N_CONTAINER_IPV4="10.117.202.1";
    N8N_CONTAINER_IPV6="2001:db8:10:117::202:1";

    RUN_CONTAINER_MAC="02:cd:f2:02:00:02";
    RUN_CONTAINER_IPV4="10.117.202.2";
    RUN_CONTAINER_IPV6="2001:db8:10:117::202:2";

# Imagem - n8n
    N8N_VERSION=${N8N_VERSION:-latest};
    N8N_IMAGE_STD="ghcr.io/n8n-io/n8n:$N8N_VERSION";
    N8N_IMAGE_ARG="$1";
    N8N_IMAGE="${N8N_IMAGE_ARG:-$N8N_IMAGE_STD}"
    echo "$N8N_IMAGE" | egrep -q '/' && docker pull $N8N_IMAGE;

# Imagem - runners
    RUNNERS_IMAGE_STD="ghcr.io/n8n-io/runners:$N8N_VERSION";
    RUNNERS_IMAGE_ARG="$2";
    RUNNERS_IMAGE="${RUNNERS_IMAGE_ARG:-$RUNNERS_IMAGE_STD}"
    echo "$RUNNERS_IMAGE" | egrep -q '/' && docker pull $RUNNERS_IMAGE;

# Volume
    DATADIR=/storage/$NAME;
    mkdir -p $DATADIR;
    chown -R 999:999 $DATADIR;

# Renovar/rodar:
    ( docker stop $NAME;    docker rm $NAME;    sync && sleep 1; ) 2>/dev/null;
    ( docker stop $RUNNER;  docker rm $RUNNER; sync && sleep 1; ) 2>/dev/null;

    # Rodar N8N
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
        -p 10202:5678 \
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
        -e N8N_RUNNERS_MODE=external \
        -e N8N_RUNNERS_BROKER_LISTEN_ADDRESS=0.0.0.0 \
        -e N8N_RUNNERS_AUTH_TOKEN=tr_secret \
        -e N8N_NATIVE_PYTHON_RUNNER=true \
        -e N8N_METRICS=true \
        \
        -e N8N_SECURE_COOKIE=false \
        -e N8N_SAMESITE_COOKIE=n8n202 \
        \
        --health-cmd="/bin/sh -c 'wget --spider -q http://localhost:5678/healthz || exit 1'" \
        --health-interval=5s \
        --health-timeout=5s \
        --health-retries=10 \
        \
        $N8N_IMAGE;

    # Rodar Runners
    docker run \
        -d --restart=always \
        --name $RUNNER -h $RLOCAL \
        --user root:root \
        \
        --network $NETWORK \
        --mac-address $RUN_CONTAINER_MAC \
        --ip=$RUN_CONTAINER_IPV4 \
        --ip6=$RUN_CONTAINER_IPV6 \
        \
        -e N8N_RUNNERS_TASK_BROKER_URI=http://$NAME:5679 \
        -e N8N_RUNNERS_AUTH_TOKEN=tr_secret \
        -e NO_COLOR=1 \
        \
        $RUNNERS_IMAGE;
    echo;


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
    #/root/n8n-builder/scripts/n8n-sqlite-user-reset.sh "$DATADIR/.n8n/database.sqlite";
    # Definindo via http
    /root/n8n-builder/scripts/n8n-http-user-setup.sh "http://$N8N_CONTAINER_IPV4:5678";

    # Iniciando n8n
    _echo_title "$0 - Iniciando N8N";
    docker start $NAME;
    echo;


# Acessando:
    # - obter nome do servidor:
    SERVER=$(hostname -f);
    PORT=48022;
    ssh -N root@$SERVER -p $PORT -L 127.0.0.1:10202:10.117.202.1:5678

# Destruir container e iniciar do zero
    docker rm -f n8n-202-runner-sqlite 2>/dev/null;
    docker rm -f n8n-202-runners       2>/dev/null;

    rm  -rf /storage/n8n-202-runner-sqlite;
    rm  -rf /storage/n8n-202-runner-sqlite;

    sh /root/n8n-builder/test-server/setup-202-n8n-sqlite-external.sh;

# http://localhost:10201/webhook/test01



