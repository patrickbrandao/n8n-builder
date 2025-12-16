#!/bin/bash

# n8n - replicar TAPI para testes locais
#   dual main, dual worker, postgres database
#   - editor: 2 
#   - worker: 2
#   - runners: 2 (um para cada worker)

# Variaveis
#====================================================================================================


    EDITOR1_NAME=n8n-241-editor-1;
    EDITOR2_NAME=n8n-241-editor-2;

    WORKER1_NAME=n8n-241-worker-1;
    WORKER2_NAME=n8n-241-worker-2;

    RUNNER1_NAME=n8n-241-runner-1;
    RUNNER2_NAME=n8n-241-runner-2;


    # Nomes de DNS
    DOMAIN=$(hostname -f);
    # - editores
    EDITOR1_FQDN="editor-241-1.$DOMAIN";
    EDITOR2_FQDN="editor-241-2.$DOMAIN";


    # md5(tulipa)
    N8N_ENCRYPTION_KEY=52169089a52705298a67f2f8d9895c76;
    N8N_LICENSE_CERT="";
    N8N_LICENSE_ACTIVATION_KEY="";
    N8N_LICENSE_TENANT_ID=1;


    # Banco de dados
    DB_POSTGRESDB_DATABASE="n8n241";
    DB_POSTGRESDB_HOST="postgres-18";
    DB_POSTGRESDB_PORT="5432";
    DB_POSTGRESDB_USER="n8n241";
    DB_POSTGRESDB_PASSWORD="tulipasql";

    #QUEUE_BULL_REDIS_HOST=redis-db-d;
    QUEUE_BULL_REDIS_HOST=redis-db;
    QUEUE_BULL_REDIS_PORT=6379
    QUEUE_BULL_REDIS_DB=241;
    QUEUE_BULL_PREFIX=bull241;
    QUEUE_BULL_REDIS_PASSWORD="";

    # Proxy
    N8N_PROXY_HOPS=1;

    # TaskRunner - Worker
    N8N_RUNNERS_ENABLED=true;
    #N8N_RUNNERS_MODE=external; # internal, external
    N8N_RUNNERS_MODE=internal;
    N8N_RUNNERS_BROKER_LISTEN_ADDRESS=0.0.0.0;
    N8N_RUNNERS_AUTH_TOKEN=tulipa;
    N8N_NATIVE_PYTHON_RUNNER=true;
    N8N_RUNNERS_MAX_CONCURRENCY=32;
    N8N_RUNNERS_AUTO_SHUTDOWN_TIMEOUT=16;



    # Imagem - n8n, n8n-private:1.121.3
    # https://github.com/n8n-io/n8n/releases
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


    # Envs
    TZ="$(timedatectl show | egrep Timezone= | cut -f2 -d=)";


    # Armazenamento
    DATADIR=/storage/n8n-241-data;
    mkdir -p "$DATADIR";
    mkdir -p "${DATADIR}/editor1";
    mkdir -p "${DATADIR}/editor2";
    mkdir -p "${DATADIR}/worker1";
    mkdir -p "${DATADIR}/worker2";
    chown 1000:1000 $DATADIR -R;


# Multimain
#====================================================================================================


#------------------------------------------------------- balance


#------------------------------------------------------- editor

    # n8n_main1
    docker rm -f $EDITOR1_NAME 2>/dev/null;
    docker run -d \
        --name $EDITOR1_NAME -h $EDITOR1_NAME.intranet.br \
        \
        --network network_public \
        --ip=10.117.241.1 \
        --ip6=2001:db8:10:117::241:1 \
        --mac-address 02:cd:f2:41:00:01 \
        \
        -e N8N_DIAGNOSTICS_ENABLED=false \
        -e N8N_USER_FOLDER=/data \
        -e N8N_ENCRYPTION_KEY="${N8N_ENCRYPTION_KEY}" \
        -e N8N_LICENSE_CERT="${N8N_LICENSE_CERT}" \
        -e N8N_LICENSE_ACTIVATION_KEY="${N8N_LICENSE_ACTIVATION_KEY}" \
        -e N8N_LICENSE_TENANT_ID="${N8N_LICENSE_TENANT_ID}" \
        -e N8N_PROXY_HOPS=$N8N_PROXY_HOPS \
        \
        -e EXECUTIONS_MODE=queue \
        \
        -e QUEUE_BULL_REDIS_HOST=redis \
        -e QUEUE_BULL_REDIS_HOST=$QUEUE_BULL_REDIS_HOST \
        -e QUEUE_BULL_REDIS_PORT=$QUEUE_BULL_REDIS_PORT \
        -e QUEUE_BULL_REDIS_DB=$QUEUE_BULL_REDIS_DB \
        -e QUEUE_BULL_PREFIX=$QUEUE_BULL_PREFIX \
        -e QUEUE_BULL_REDIS_PASSWORD=$QUEUE_BULL_REDIS_PASSWORD \
        \
        -e N8N_MULTI_MAIN_SETUP_ENABLED=true \
        \
        -e DB_TYPE=postgresdb \
        -e DB_POSTGRESDB_DATABASE=$DB_POSTGRESDB_DATABASE \
        -e DB_POSTGRESDB_HOST=$DB_POSTGRESDB_HOST \
        -e DB_POSTGRESDB_PORT=$DB_POSTGRESDB_PORT \
        -e DB_POSTGRESDB_USER=$DB_POSTGRESDB_USER \
        -e DB_POSTGRESDB_PASSWORD=$DB_POSTGRESDB_PASSWORD \
        \
        -e N8N_METRICS=true \
        -v "${DATADIR}/editor1:/data" \
        \
        --label "traefik.enable=true" \
        --label "traefik.http.routers.$EDITOR1_NAME.rule=Host(\`$EDITOR1_FQDN\`)" \
        --label "traefik.http.routers.$EDITOR1_NAME.entrypoints=web,websecure" \
        --label "traefik.http.routers.$EDITOR1_NAME.tls=true" \
        --label "traefik.http.routers.$EDITOR1_NAME.tls.certresolver=letsencrypt" \
        --label "traefik.http.services.$EDITOR1_NAME.loadbalancer.server.port=5678" \
        \
        "$N8N_IMAGE";

    # Aguardar setup do editor
    echo "# Aguardando setup do editor 1..."; sleep 5;

    # n8n_main2
    docker rm -f $EDITOR2_NAME 2>/dev/null;
    docker run -d \
        --name $EDITOR2_NAME -h $EDITOR2_NAME.intranet.br \
        \
        --network network_public \
        --ip=10.117.241.2 \
        --ip6=2001:db8:10:117::241:2 \
        --mac-address 02:cd:f2:41:00:02 \
        \
        -e N8N_DIAGNOSTICS_ENABLED=false \
        -e N8N_USER_FOLDER=/data \
        -e N8N_ENCRYPTION_KEY="${N8N_ENCRYPTION_KEY}" \
        -e N8N_LICENSE_CERT="${N8N_LICENSE_CERT}" \
        -e N8N_LICENSE_ACTIVATION_KEY="${N8N_LICENSE_ACTIVATION_KEY}" \
        -e N8N_LICENSE_TENANT_ID="${N8N_LICENSE_TENANT_ID}" \
        -e N8N_PROXY_HOPS=$N8N_PROXY_HOPS \
        \
        -e EXECUTIONS_MODE=queue \
        \
        -e QUEUE_BULL_REDIS_HOST=redis \
        -e QUEUE_BULL_REDIS_HOST=$QUEUE_BULL_REDIS_HOST \
        -e QUEUE_BULL_REDIS_PORT=$QUEUE_BULL_REDIS_PORT \
        -e QUEUE_BULL_REDIS_DB=$QUEUE_BULL_REDIS_DB \
        -e QUEUE_BULL_PREFIX=$QUEUE_BULL_PREFIX \
        -e QUEUE_BULL_REDIS_PASSWORD=$QUEUE_BULL_REDIS_PASSWORD \
        \
        -e N8N_MULTI_MAIN_SETUP_ENABLED=true \
        \
        -e DB_TYPE=postgresdb \
        -e DB_POSTGRESDB_DATABASE=$DB_POSTGRESDB_DATABASE \
        -e DB_POSTGRESDB_HOST=$DB_POSTGRESDB_HOST \
        -e DB_POSTGRESDB_PORT=$DB_POSTGRESDB_PORT \
        -e DB_POSTGRESDB_USER=$DB_POSTGRESDB_USER \
        -e DB_POSTGRESDB_PASSWORD=$DB_POSTGRESDB_PASSWORD \
        \
        -e N8N_METRICS=true \
        -v "${DATADIR}/editor2:/data" \
        \
        --label "traefik.enable=true" \
        --label "traefik.http.routers.$EDITOR2_NAME.rule=Host(\`$EDITOR2_FQDN\`)" \
        --label "traefik.http.routers.$EDITOR2_NAME.entrypoints=web,websecure" \
        --label "traefik.http.routers.$EDITOR2_NAME.tls=true" \
        --label "traefik.http.routers.$EDITOR2_NAME.tls.certresolver=letsencrypt" \
        --label "traefik.http.services.$EDITOR2_NAME.loadbalancer.server.port=5678" \
        \
        "$N8N_IMAGE";



#------------------------------------------------------- worker


    # n8n_worker1
    docker rm -f $WORKER1_NAME 2>/dev/null;
    docker run -d \
        --name $WORKER1_NAME -h $WORKER1_NAME.intranet.br \
        \
        --network network_public \
        --ip=10.117.241.11 \
        --ip6=2001:db8:10:117::241:11 \
        --mac-address 02:cd:f2:41:00:11 \
        \
        -e N8N_DIAGNOSTICS_ENABLED=false \
        -e N8N_USER_FOLDER=/data \
        -e N8N_ENCRYPTION_KEY="${N8N_ENCRYPTION_KEY}" \
        -e N8N_LICENSE_CERT="${N8N_LICENSE_CERT}" \
        -e N8N_LICENSE_ACTIVATION_KEY="${N8N_LICENSE_ACTIVATION_KEY}" \
        -e N8N_LICENSE_TENANT_ID="${N8N_LICENSE_TENANT_ID}" \
        \
        -e EXECUTIONS_MODE=queue \
        -e QUEUE_BULL_REDIS_HOST=$QUEUE_BULL_REDIS_HOST \
        -e QUEUE_BULL_REDIS_PORT=$QUEUE_BULL_REDIS_PORT \
        -e QUEUE_BULL_REDIS_DB=$QUEUE_BULL_REDIS_DB \
        -e QUEUE_BULL_PREFIX=$QUEUE_BULL_PREFIX \
        -e QUEUE_BULL_REDIS_PASSWORD=$QUEUE_BULL_REDIS_PASSWORD \
        -e QUEUE_HEALTH_CHECK_ACTIVE=true \
        \
        -e DB_TYPE=postgresdb \
        -e DB_POSTGRESDB_DATABASE=$DB_POSTGRESDB_DATABASE \
        -e DB_POSTGRESDB_HOST=$DB_POSTGRESDB_HOST \
        -e DB_POSTGRESDB_PORT=$DB_POSTGRESDB_PORT \
        -e DB_POSTGRESDB_USER=$DB_POSTGRESDB_USER \
        -e DB_POSTGRESDB_PASSWORD=$DB_POSTGRESDB_PASSWORD \
        \
        -e N8N_RUNNERS_ENABLED=true \
        -e N8N_RUNNERS_MODE=external \
        -e N8N_RUNNERS_BROKER_LISTEN_ADDRESS=$N8N_RUNNERS_BROKER_LISTEN_ADDRESS \
        -e N8N_RUNNERS_AUTH_TOKEN=$N8N_RUNNERS_AUTH_TOKEN \
        -e N8N_NATIVE_PYTHON_RUNNER=true \
        \
        -v "${DATADIR}/worker1:/data" \
        \
        "$N8N_IMAGE" \
        worker;

        #-e N8N_CONCURRENCY_PRODUCTION_LIMIT=10 \

# n8n_worker1_runners
    docker rm -f $RUNNER1_NAME 2>/dev/null;
    docker run -d \
        --name $RUNNER1_NAME -h $RUNNER1_NAME.intranet.br \
        \
        --network network_public \
        --ip=10.117.241.12 \
        --ip6=2001:db8:10:117::241:12 \
        --mac-address 02:cd:f2:41:00:12 \
        \
        -e N8N_RUNNERS_TASK_BROKER_URI=http://$WORKER1_NAME:5679 \
        -e N8N_RUNNERS_AUTH_TOKEN=$N8N_RUNNERS_AUTH_TOKEN \
        -e NO_COLOR=1 \
        \
        "$RUNNERS_IMAGE";

# n8n_worker2
    docker rm -f $WORKER2_NAME 2>/dev/null;
    docker run -d \
        --name $WORKER2_NAME -h $WORKER2_NAME.intranet.br \
        \
        --network network_public \
        --ip=10.117.241.21 \
        --ip6=2001:db8:10:117::241:21 \
        --mac-address 02:cd:f2:41:00:21 \
        \
        -e N8N_DIAGNOSTICS_ENABLED=false \
        -e N8N_USER_FOLDER=/data \
        -e N8N_ENCRYPTION_KEY="${N8N_ENCRYPTION_KEY}" \
        -e N8N_LICENSE_CERT="${N8N_LICENSE_CERT}" \
        -e N8N_LICENSE_ACTIVATION_KEY="${N8N_LICENSE_ACTIVATION_KEY}" \
        -e N8N_LICENSE_TENANT_ID="${N8N_LICENSE_TENANT_ID}" \
        \
        -e EXECUTIONS_MODE=queue \
        -e QUEUE_BULL_REDIS_HOST=$QUEUE_BULL_REDIS_HOST \
        -e QUEUE_BULL_REDIS_PORT=$QUEUE_BULL_REDIS_PORT \
        -e QUEUE_BULL_REDIS_DB=$QUEUE_BULL_REDIS_DB \
        -e QUEUE_BULL_PREFIX=$QUEUE_BULL_PREFIX \
        -e QUEUE_BULL_REDIS_PASSWORD=$QUEUE_BULL_REDIS_PASSWORD \
        -e QUEUE_HEALTH_CHECK_ACTIVE=true \
        \
        -e DB_TYPE=postgresdb \
        -e DB_POSTGRESDB_DATABASE=$DB_POSTGRESDB_DATABASE \
        -e DB_POSTGRESDB_HOST=$DB_POSTGRESDB_HOST \
        -e DB_POSTGRESDB_PORT=$DB_POSTGRESDB_PORT \
        -e DB_POSTGRESDB_USER=$DB_POSTGRESDB_USER \
        -e DB_POSTGRESDB_PASSWORD=$DB_POSTGRESDB_PASSWORD \
        \
        -e N8N_RUNNERS_ENABLED=true \
        -e N8N_RUNNERS_MODE=external \
        -e N8N_RUNNERS_BROKER_LISTEN_ADDRESS=$N8N_RUNNERS_BROKER_LISTEN_ADDRESS \
        -e N8N_RUNNERS_AUTH_TOKEN=$N8N_RUNNERS_AUTH_TOKEN \
        -e N8N_NATIVE_PYTHON_RUNNER=true \
        \
        -v "${DATADIR}/worker2:/data" \
        \
        "$N8N_IMAGE" \
        worker;

        #-e N8N_CONCURRENCY_PRODUCTION_LIMIT=10 \


# n8n_worker2_runners
    docker rm -f $RUNNER2_NAME 2>/dev/null;
    docker run -d \
        --name $RUNNER2_NAME -h $RUNNER2_NAME.intranet.br \
        \
        --network network_public \
        --ip=10.117.241.22 \
        --ip6=2001:db8:10:117::241:22 \
        --mac-address 02:cd:f2:41:00:22 \
        \
        -e N8N_RUNNERS_TASK_BROKER_URI=http://$WORKER2_NAME:5679 \
        -e N8N_RUNNERS_AUTH_TOKEN=$N8N_RUNNERS_AUTH_TOKEN \
        -e NO_COLOR=1 \
        \
        "$RUNNERS_IMAGE";



# Acesso
    echo;
    echo " Acesso";
    echo "  Editor 1.....: https://$EDITOR1_FQDN";
    echo "  Editor 2.....: https://$EDITOR2_FQDN";
    echo;


exit 0;


# Parar servicos
    docker stop n8n-241-editor-1;
    docker stop n8n-241-editor-2;
    docker stop n8n-241-worker-1;
    docker stop n8n-241-runner-1;
    docker stop n8n-241-worker-2;
    docker stop n8n-241-runner-2;

# Iniciar servicos
    docker start n8n-241-editor-1;
    docker start n8n-241-editor-2;
    docker start n8n-241-worker-1;
    docker start n8n-241-runner-1;
    docker start n8n-241-worker-2;
    docker start n8n-241-runner-2;



# Preparar postgres
#---------------------------------------------------------------------------------

    docker exec -it --user postgres postgres-18 psql -U postgres;

    -- usuario do container local:
    CREATE USER n8n241
        WITH PASSWORD 'tulipasql'
            CREATEDB
            LOGIN;

    -- criar db e usuario do n8n
    CREATE DATABASE n8n241
        WITH 
        OWNER = n8n241
            ENCODING = 'UTF8'
            TABLESPACE = pg_default
            IS_TEMPLATE = False
            CONNECTION LIMIT = -1;

    -- Conectar no banco:
    \c n8n241;

    -- Sair
    \q


#---------------------------------------------------------------------------------



