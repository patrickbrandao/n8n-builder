#!/bin/bash

# n8n
#   - single main, single worker, postgres database
#   - worker: 1
#   - runners: 1, conectado no worker, js e py

# Funcoes
    _echo_title(){ echo; printf "\033[33;7m > \033[0m\033[32;7m $1 \033[0m\n"; };

# Variaveis
    NAME="n8n-204-single-sqlite-wi";
    LOCAL="$NAME.intranet.br";

    WORKER="n8n-204-worker";
    WLOCAL="$WORKER.intranet.br";

# Rede
    NETWORK="network_public";
    N8N_CONTAINER_MAC="02:cd:f2:04:00:01";
    N8N_CONTAINER_IPV4="10.117.204.1";
    N8N_CONTAINER_IPV6="2001:db8:10:117::204:1";

    WORKER_CONTAINER_MAC="02:cd:f2:04:00:02";
    WORKER_CONTAINER_IPV4="10.117.204.2";
    WORKER_CONTAINER_IPV6="2001:db8:10:117::204:2";

    RUNNER_CONTAINER_MAC="02:cd:f2:04:00:03";
    RUNNER_CONTAINER_IPV4="10.117.204.3";
    RUNNER_CONTAINER_IPV6="2001:db8:10:117::204:3";

# Imagem - n8n
    N8N_VERSION=${N8N_VERSION:-latest};
    N8N_IMAGE_STD="ghcr.io/n8n-io/n8n:$N8N_VERSION";
    N8N_IMAGE_ARG="$1";
    N8N_IMAGE="${N8N_IMAGE_ARG:-$N8N_IMAGE_STD}"
    echo "$N8N_IMAGE" | egrep -q '/' && docker pull $N8N_IMAGE;


# Volume
    DATADIR=/storage/$NAME;
    mkdir -p $DATADIR;
    mkdir -p $DATADIR/n8n-worker;
    mkdir -p $DATADIR/n8n-main;
    chown -R 999:999 $DATADIR;

# Renovar/rodar:
    _echo_title "$0 - Obtendo imagem"
    ( docker stop $NAME; docker rm $NAME; sync && sleep 1; ) 2>/dev/null;

    # Criar editor
    _echo_title "$0 - Criando e inicializando N8N Editor";
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
        -p 10204:5678 \
        \
        -v $DATADIR/n8n-main:/n8n \
        \
        -e N8N_ENCRYPTION_KEY=tulipa \
        -e N8N_DIAGNOSTICS_ENABLED=false \
        -e N8N_USER_FOLDER=/n8n/main \
        \
        -e EXECUTIONS_MODE=queue \
        -e QUEUE_BULL_REDIS_HOST=redis-db \
        -e QUEUE_BULL_REDIS_PORT=6379 \
        -e QUEUE_BULL_REDIS_DB=204 \
        -e QUEUE_BULL_PREFIX=bull204 \
        -e QUEUE_HEALTH_CHECK_ACTIVE=true \
        \
        -e N8N_CONCURRENCY_PRODUCTION_LIMIT=10 \
        \
        -e DB_TYPE=postgresdb \
        -e DB_POSTGRESDB_HOST=postgres-18 \
        -e DB_POSTGRESDB_PORT=5432 \
        -e DB_POSTGRESDB_USER=n8n204 \
        -e DB_POSTGRESDB_PASSWORD=tulipasql \
        -e DB_POSTGRESDB_DATABASE=n8n204 \
        -e DB_POSTGRESDB_SCHEMA=public \
        \
        -e N8N_METRICS=true \
        \
        -e N8N_SECURE_COOKIE=false \
        -e N8N_SAMESITE_COOKIE=n8n204 \
        \
        --health-cmd="/bin/sh -c 'wget --spider -q http://n8n:5678/healthz || exit 1'" \
        --health-interval=5s \
        --health-timeout=5s \
        --health-retries=10 \
        \
        $N8N_IMAGE;



    # Criar worker em modo internal
    _echo_title "$0 - Criando e inicializando N8N Worker";
    docker run \
        -d --restart=always \
        --name $WORKER -h $WLOCAL \
        --user root:root \
        \
        --network $NETWORK \
        --mac-address $WORKER_CONTAINER_MAC \
        --ip=$WORKER_CONTAINER_IPV4 \
        --ip6=$WORKER_CONTAINER_IPV6 \
        \
        -v $DATADIR/n8n-worker:/n8n \
        \
        -e N8N_DIAGNOSTICS_ENABLED=false \
        -e N8N_USER_FOLDER=/n8n/worker1 \
        -e N8N_ENCRYPTION_KEY=tulipa \
        \
        -e EXECUTIONS_MODE=queue \
        -e QUEUE_BULL_REDIS_HOST=redis-db \
        -e QUEUE_BULL_REDIS_PORT=6379 \
        -e QUEUE_BULL_REDIS_DB=204 \
        -e QUEUE_BULL_PREFIX=bull204 \
        -e QUEUE_HEALTH_CHECK_ACTIVE=true \
        \
        -e N8N_CONCURRENCY_PRODUCTION_LIMIT=10 \
        \
        -e DB_TYPE=postgresdb \
        -e DB_POSTGRESDB_HOST=postgres-18 \
        -e DB_POSTGRESDB_PORT=5432 \
        -e DB_POSTGRESDB_USER=n8n204 \
        -e DB_POSTGRESDB_PASSWORD=tulipasql \
        -e DB_POSTGRESDB_DATABASE=n8n204 \
        -e DB_POSTGRESDB_SCHEMA=public \
        \
        -e N8N_RUNNERS_ENABLED=true \
        -e N8N_RUNNERS_MODE=internal \
        -e N8N_NATIVE_PYTHON_RUNNER=true \
        \
        --health-cmd="/bin/sh -c 'wget --spider -q http://n8n_worker1:5678/healthz || exit 1'" \
        --health-interval=5s \
        --health-timeout=5s \
        --health-retries=10 \
        \
        $N8N_IMAGE worker --concurrency=32;


exit;

# Preparar postgres
#---------------------------------------------------------------------------------

    docker exec -it --user postgres postgres-18 psql -U postgres;

    -- usuario do container local:
    CREATE USER n8n204
        WITH PASSWORD 'tulipasql'
            CREATEDB
            LOGIN;

    -- criar db e usuario do n8n
    CREATE DATABASE n8n204
        WITH 
        OWNER = n8n204
            ENCODING = 'UTF8'
            TABLESPACE = pg_default
            IS_TEMPLATE = False
            CONNECTION LIMIT = -1;

    -- Conectar no banco:
    \c n8n204;

    -- Sair
    \q


#---------------------------------------------------------------------------------

    # Listar tabelas
    docker exec -it --user postgres postgres-18 psql -d n8n204 -U postgres -c "\dt";

    # Listar projetos
    docker exec --user postgres postgres-18 psql -d n8n204 -U postgres -c "SELECT * FROM project ORDER BY id;"

