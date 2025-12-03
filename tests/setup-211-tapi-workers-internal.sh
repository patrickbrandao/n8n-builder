#!/bin/bash

# n8n - replicar TAPI para testes locais
#   - single main, single worker, postgres database
#   - worker: 1 (internal)
#   - runners: 2, separado, runner para js, runner para py

# Variaveis do N8N
#====================================================================================================

    EDITOR_NAME=n8n-211-editor;
    WEBHOOK_NAME=n8n-211-webhook;
    MCPSERVER_NAME=n8n-211-mcp-server;
    WORKER_NAME=n8n-211-worker;

    # Versao N8N
    SERVER_FQDN=$(hostname -f);
    FQDN_EDITOR=editor-211.$SERVER_FQDN;
    FQDN_WEBHOOKS=ws-211.$SERVER_FQDN;
    FQDN_MCP=mcp-211.$SERVER_FQDN;

    # Armazenamento
    DATADIR=/storage/n8n-211-data;
    NODEDIR=/storage/n8n-211-nodes;
    mkdir -p $DATADIR; chown 1000:1000 $DATADIR -R;
    mkdir -p $NODEDIR; chown 1000:1000 $NODEDIR -R;

    # Imagem - n8n, n8n-private:1.121.3
    # https://github.com/n8n-io/n8n/releases
    N8N_VERSION=${N8N_VERSION:-latest};
    N8N_IMAGE_STD="ghcr.io/n8n-io/n8n:$N8N_VERSION";
    N8N_IMAGE_ARG="$1";
    N8N_IMAGE="${N8N_IMAGE_ARG:-$N8N_IMAGE_STD}"
    echo "$N8N_IMAGE" | egrep -q '/' && docker pull $N8N_IMAGE;

    # Envs
    TZ="$(timedatectl show | egrep Timezone= | cut -f2 -d=)";
    EMAIL="root@intranet.br";
    [ -f /etc/email ] && EMAIL=$(head -1 /etc/email);

    # md5(tulipa)
    N8N_ENCRYPTION_KEY=52169089a52705298a67f2f8d9895c76;
    N8N_PERSONALIZATION_ENABLED=true;
    N8N_BLOCK_ENV_ACCESS_IN_NODE=false;
    N8N_GIT_NODE_DISABLE_BARE_REPOS=true;

    # genericos
    N8N_DIAGNOSTICS_ENABLED="false";
    N8N_ENFORCE_SETTINGS_FILE_PERMISSIONS="true";
    OFFLOAD_MANUAL_EXECUTIONS_TO_WORKERS="true";

    # proxy
    N8N_PROXY_HOPS=1
    # Proxy
    #HTTP_PROXY=http://proxy:tulipa@mitm-proxy:8080;
    #HTTPS_PROXY=http://proxy:tulipa@mitm-proxy:8080;
    #NODE_TLS_REJECT_UNAUTHORIZED=0;  # Para ignorar erros SSL do proxy


    # Banco de dados
    DB_POSTGRESDB_DATABASE="n8n211";
    DB_POSTGRESDB_HOST="postgres-18";
    DB_POSTGRESDB_PORT="5432";
    DB_POSTGRESDB_USER="n8n211";
    DB_POSTGRESDB_PASSWORD="tulipasql";

    QUEUE_BULL_REDIS_HOST=redis-db;
    QUEUE_BULL_REDIS_PORT=6379;
    QUEUE_BULL_REDIS_DB=211;
    QUEUE_BULL_PREFIX=bull231;
    QUEUE_BULL_REDIS_PASSWORD="";

    N8N_ENDPOINT_WEBHOOK=webhook;
    N8N_ENDPOINT_WEBHOOK_TEST=ws-test;
    N8N_ENDPOINT_WEBHOOK_WAIT=ws-wait;
    N8N_ENDPOINT_MCP=mcp;
    N8N_ENDPOINT_MCP_TEST=mcp-test;

    # Achave de API do assistente de IA
    N8N_AI_ENABLED="true";
    N8N_AI_ANTHROPIC_KEY=$(head -1 /etc/anthropic_key);
    LANGSMITH_API_KEY=$(head -1 /etc/langsmith_key);

    # Em producao
    # - smtp out
    N8N_SMTP_HOST="postmail";
    N8N_SMTP_PORT="587";
    N8N_SMTP_USER="sender@ajustefino.com";
    N8N_SMTP_PASS="xpto123456";
    N8N_SMTP_SENDER="contato@ajustefino.com";

    # - assistente de ia
    N8N_AI_ASSISTANT_BASE_URL="http://mitm-aia:8080";
    DEFAULT_SERVICE_BASE_URL="http://mitm-aia:8080";

    # TaskRunner - Worker
    N8N_RUNNERS_ENABLED=true;
    N8N_RUNNERS_MODE=internal;
    N8N_RUNNERS_BROKER_LISTEN_ADDRESS=0.0.0.0;
    N8N_RUNNERS_AUTH_TOKEN=tulipa;
    N8N_NATIVE_PYTHON_RUNNER=true;
    N8N_RUNNERS_MAX_CONCURRENCY=32;
    N8N_RUNNERS_AUTO_SHUTDOWN_TIMEOUT=16;


# Preparar ambiente
#====================================================================================================

    # Obter ultima imagem:
    [ "$N8N_PREFIX" = "n8nio/n8n" ] && docker pull $N8N_IMAGE 2>/dev/null 1>/dev/null;



# Common args
#====================================================================================================


    # - opcoes gerais
    (
        echo "    \\";
        echo "    -e TZ=$TZ \\";
        echo "    -e GENERIC_TIMEZONE=$TZ \\";
        echo "    -e NODE_ENV=production \\";
        echo "    \\";
    ) > /tmp/setup-n8n-211-01-defaults.txt;


    # opcoes do N8N - proprias
    (
        echo "    \\";
        echo "    -e N8N_AI_ENABLED=$N8N_AI_ENABLED \\";
        echo "    -e N8N_AI_ANTHROPIC_KEY=$N8N_AI_ANTHROPIC_KEY \\";
        echo "    -e N8N_AI_ASSISTANT_BASE_URL=$N8N_AI_ASSISTANT_BASE_URL \\";
        echo "    -e DEFAULT_SERVICE_BASE_URL=$DEFAULT_SERVICE_BASE_URL \\";
        echo "    -e LANGSMITH_API_KEY=$LANGSMITH_API_KEY \\";
        echo "    \\";

        echo "    \\";
        echo "    -e HTTP_PROXY=$HTTP_PROXY \\";
        echo "    -e HTTPS_PROXY=$HTTPS_PROXY \\";
        echo "    -e NODE_TLS_REJECT_UNAUTHORIZED=$NODE_TLS_REJECT_UNAUTHORIZED \\";
        echo "    \\";

        echo "    -e EXPRESS_TRUST_PROXY=true \\";
        echo "    -e N8N_PROXY_HOPS=$N8N_PROXY_HOPS \\";
        echo "    \\";
        echo "    -e N8N_ENDPOINT_WEBHOOK=webhook \\";
        echo "    -e N8N_ENDPOINT_WEBHOOK_TEST=ws-test \\";
        echo "    -e N8N_ENDPOINT_WEBHOOK_WAIT=ws-wait \\";
        echo "    -e N8N_ENDPOINT_MCP=mcp \\";
        echo "    -e N8N_ENDPOINT_MCP_TEST=mcp-test \\";
        echo "    \\";
        echo "    -e N8N_BLOCK_ENV_ACCESS_IN_NODE=$N8N_BLOCK_ENV_ACCESS_IN_NODE \\";
        echo "    -e N8N_GIT_NODE_DISABLE_BARE_REPOS=$N8N_GIT_NODE_DISABLE_BARE_REPOS \\";
        echo "    \\";
        echo "    -e N8N_CUSTOM_EXTENSIONS=/data/nodes \\";
        echo "    -e N8N_COMMUNITY_PACKAGES_ALLOW_TOOL_USAGE=true \\";
        echo "    -e N8N_COMMUNITY_PACKAGES_ENABLED=true \\";
        echo "    -e N8N_DIAGNOSTICS_ENABLED=$N8N_DIAGNOSTICS_ENABLED \\";
        echo "    -e N8N_ENCRYPTION_KEY=$N8N_ENCRYPTION_KEY \\";
        echo "    -e N8N_PERSONALIZATION_ENABLED=$N8N_PERSONALIZATION_ENABLED \\";
        echo "    -e N8N_ENFORCE_SETTINGS_FILE_PERMISSIONS=$N8N_ENFORCE_SETTINGS_FILE_PERMISSIONS \\";
        echo "    -e 'NODE_FUNCTION_ALLOW_BUILTIN=*' \\";
        echo "    -e NODE_FUNCTION_ALLOW_EXTERNAL=moment,lodash,axios \\";
        echo "    -e N8N_HIDE_USAGE_PAGE=false \\";
        echo "    -e N8N_HOST=$SERVER_FQDN \\";
        echo "    -e N8N_LOG_LEVEL=info \\";
        echo "    -e N8N_METRICS=true \\";
        echo "    -e N8N_NODE_PATH=/data/nodes \\";
        echo "    -e N8N_ONBOARDING_FLOW_DISABLED=true \\";
        echo "    -e N8N_PAYLOAD_SIZE_MAX=512 \\";
        echo "    -e N8N_PORT=5678 \\";
        echo "    -e N8N_PROTOCOL=https \\";
        echo "    -e N8N_PUBLIC_API_SWAGGERUI_DISABLED=false \\";
        echo "    -e N8N_REINSTALL_MISSING_PACKAGES=true \\";
        echo "    -e N8N_TEMPLATES_ENABLED=true \\";
        echo "    -e N8N_TRUST_PROXY=true \\";
        echo "    -e N8N_VERSION_NOTIFICATIONS_ENABLED=true \\";
        echo "    -e N8N_WORKFLOW_TAGS_DISABLED=false \\";
        echo "    \\";
        echo "    \\";
    ) > /tmp/setup-n8n-211-02-common.txt;


    # opcoes do n8n - smtp
    (
        echo "    \\";
        echo "    -e N8N_EMAIL_MODE=smtp \\";
        echo "    -e N8N_SMTP_HOST=$N8N_SMTP_HOST \\";
        echo "    -e N8N_SMTP_PORT=$N8N_SMTP_PORT \\";
        echo "    -e N8N_SMTP_USER=$N8N_SMTP_USER \\";
        echo "    -e N8N_SMTP_PASS=$N8N_SMTP_PASS \\";
        echo "    -e N8N_SMTP_SENDER=$N8N_SMTP_SENDER \\";
        echo "    -e N8N_SMTP_SSL=true \\";
        echo "    \\";
    ) > /tmp/setup-n8n-211-03-smtp.txt;


    # opcoes do n8n - externas
    (
        echo "    \\";
        echo "    \\";
        echo "    \\";
    ) > /tmp/setup-n8n-211-04-external.txt;


    # opcoes do n8n - opcoes de execucao
    (
        echo "    \\";
        echo "    -e EXECUTIONS_DATA_PRUNE=true \\";
        echo "    -e EXECUTIONS_DATA_MAX_AGE=336 \\";
        echo "    -e EXECUTIONS_DATA_PRUNE_MAX_COUNT=2048 \\";
        echo "    -e EXECUTIONS_DATA_PRUNE_HARD_DELETE_INTERVAL=15 \\";
        echo "    -e EXECUTIONS_DATA_PRUNE_SOFT_DELETE_INTERVAL=60 \\";
        echo "    -e EXECUTIONS_DATA_SAVE_ON_ERROR=all \\";
        echo "    -e EXECUTIONS_DATA_SAVE_ON_SUCCESS=all \\";
        echo "    -e EXECUTIONS_DATA_SAVE_ON_PROGRESS=true \\";
        echo "    -e EXECUTIONS_DATA_SAVE_MANUAL_EXECUTIONS=true \\";
        echo "    \\";
        echo "    -e OFFLOAD_MANUAL_EXECUTIONS_TO_WORKERS=$OFFLOAD_MANUAL_EXECUTIONS_TO_WORKERS \\";
        echo "    \\";
    ) > /tmp/setup-n8n-211-05-exec.txt

    # opcoes do n8n - banco de dados
    (
        echo "    \\";
        echo "    -e DB_TYPE=postgresdb \\";
        echo "    -e DB_POSTGRESDB_DATABASE=$DB_POSTGRESDB_DATABASE \\";
        echo "    -e DB_POSTGRESDB_HOST=$DB_POSTGRESDB_HOST \\";
        echo "    -e DB_POSTGRESDB_PORT=$DB_POSTGRESDB_PORT \\";
        echo "    -e DB_POSTGRESDB_USER=$DB_POSTGRESDB_USER \\";
        echo "    -e DB_POSTGRESDB_PASSWORD=$DB_POSTGRESDB_PASSWORD \\";
        echo "    \\";
    ) > /tmp/setup-n8n-211-06-database.txt;

    # opcoes do n8n - editor
    (
        echo "    \\";
        echo "    -e N8N_EDITOR_BASE_URL=https://$FQDN_EDITOR \\";
        echo "    -e WEBHOOK_URL=https://$FQDN_WEBHOOKS/ \\";
        echo "    \\";
    ) > /tmp/setup-n8n-211-07-editor.txt

    # opcoes do n8n - redis
    (
        echo "    \\";
        echo "    -e EXECUTIONS_MODE=queue \\";
        echo "    \\";
        echo "    -e QUEUE_BULL_REDIS_HOST=$QUEUE_BULL_REDIS_HOST \\";
        echo "    -e QUEUE_BULL_REDIS_PORT=$QUEUE_BULL_REDIS_PORT \\";
        echo "    -e QUEUE_BULL_REDIS_DB=$QUEUE_BULL_REDIS_DB \\";
        echo "    -e QUEUE_BULL_PREFIX=$QUEUE_BULL_PREFIX \\";
        echo "    -e QUEUE_BULL_REDIS_PASSWORD=$QUEUE_BULL_REDIS_PASSWORD \\";
        echo "    \\";
        echo "    -e EXECUTIONS_TIMEOUT=1800 \\";
        echo "    -e EXECUTIONS_TIMEOUT_MAX=1800 \\";
        echo "    \\";
    ) > /tmp/setup-n8n-211-08-redis.txt;

    # modo de runner de todos os containers (containers: editor, webhook e mcp)
    (
        echo "    \\";
        # modo interno
        echo "    -e N8N_RUNNERS_ENABLED=$N8N_RUNNERS_ENABLED \\";
        echo "    -e N8N_RUNNERS_MODE=$N8N_RUNNERS_MODE \\";
        echo "    \\";
    ) > /tmp/setup-n8n-211-10-runners.txt;



# EDITOR
#====================================================================================================

    # Script do editor
    (
        echo '#!/bin/sh';
        echo;
        echo "docker stop $EDITOR_NAME;"
        echo "docker rm   $EDITOR_NAME;"
        echo
        echo "docker run \\"
        echo "    -d --restart=always \\"
        echo "    --name $EDITOR_NAME -h $EDITOR_NAME.intranet.br \\"
        echo "    \\"
        echo "    --network network_public \\"
        echo "    --ip=10.117.211.1 \\"
        echo "    --ip6=2001:db8:10:117::211:1 \\"
        echo "    --mac-address '02:cd:f2:11:00:01' \\";
        echo "    \\"

        cat /tmp/setup-n8n-211-01-defaults.txt;
        cat /tmp/setup-n8n-211-02-common.txt;
        cat /tmp/setup-n8n-211-03-smtp.txt;
        cat /tmp/setup-n8n-211-04-external.txt;
        cat /tmp/setup-n8n-211-05-exec.txt;
        cat /tmp/setup-n8n-211-06-database.txt;
        cat /tmp/setup-n8n-211-07-editor.txt;
        cat /tmp/setup-n8n-211-08-redis.txt;
        cat /tmp/setup-n8n-211-10-runners.txt;
        echo "    \\";

        echo "    --mount type=bind,source=$DATADIR,destination=/home/node/.n8n,readonly=false \\";
        echo "    --mount type=bind,source=$NODEDIR,destination=/data/nodes,readonly=false \\";
        echo "    \\";

        echo "    --label \"traefik.enable=true\" \\";
        echo "    --label \"traefik.http.routers.$EDITOR_NAME.rule=Host(\\\`$FQDN_EDITOR\\\`)\" \\";
        echo "    --label \"traefik.http.routers.$EDITOR_NAME.entrypoints=web,websecure\" \\";
        echo "    --label \"traefik.http.routers.$EDITOR_NAME.tls=true\" \\";
        echo "    --label \"traefik.http.routers.$EDITOR_NAME.tls.certresolver=letsencrypt\" \\";
        echo "    --label \"traefik.http.services.$EDITOR_NAME.loadbalancer.server.port=5678\" \\";
        echo "    \\";
        echo "    $N8N_IMAGE start";
        echo;
    ) > /tmp/setup-n8n-211-editor.sh;


# WEBHOOK
#====================================================================================================

    # Script do editor
    (
        echo '#!/bin/sh';
        echo;
        echo "docker stop $WEBHOOK_NAME;"
        echo "docker rm   $WEBHOOK_NAME;"
        echo
        echo "docker run \\"
        echo "    -d --restart=always \\"
        echo "    --name $WEBHOOK_NAME -h $WEBHOOK_NAME.intranet.br \\"
        echo "    \\"

        echo "    --network network_public \\"
        echo "    --ip=10.117.211.2 \\"
        echo "    --ip6=2001:db8:10:117::211:2 \\"
        echo "    --mac-address '02:cd:f2:11:00:02' \\";
        echo "    \\";

        cat /tmp/setup-n8n-211-01-defaults.txt;
        cat /tmp/setup-n8n-211-02-common.txt;
        cat /tmp/setup-n8n-211-03-smtp.txt;
        cat /tmp/setup-n8n-211-04-external.txt;
        cat /tmp/setup-n8n-211-05-exec.txt;
        cat /tmp/setup-n8n-211-06-database.txt;
        cat /tmp/setup-n8n-211-07-editor.txt;
        cat /tmp/setup-n8n-211-08-redis.txt;
        cat /tmp/setup-n8n-211-10-runners.txt;
        echo "    \\";

        echo "    --mount type=bind,source=$DATADIR,destination=/home/node/.n8n,readonly=false \\";
        echo "    --mount type=bind,source=$NODEDIR,destination=/data/nodes,readonly=false \\";
        echo "    \\";

        echo "    --label \"traefik.enable=true\" \\"
        #echo "    --label \"traefik.http.routers.$WEBHOOK_NAME.rule=Host(\\\`$FQDN_WEBHOOKS\\\`)\" \\";
        echo "    --label \"traefik.http.routers.$WEBHOOK_NAME.rule=Host(\\\`$FQDN_WEBHOOKS\\\`) || Host(\\\`$FQDN_MCP\\\`)\" \\";
        echo "    --label \"traefik.http.routers.$WEBHOOK_NAME.entrypoints=web,websecure\" \\";
        echo "    --label \"traefik.http.routers.$WEBHOOK_NAME.service=$WEBHOOK_NAME\" \\";
        echo "    --label \"traefik.http.routers.$WEBHOOK_NAME.tls=true\" \\";
        echo "    --label \"traefik.http.routers.$WEBHOOK_NAME.tls.certresolver=letsencrypt\" \\";
        echo "    --label \"traefik.http.services.$WEBHOOK_NAME.loadbalancer.server.port=5678\" \\";
        echo "    \\";

        echo "    $N8N_IMAGE webhook";
        echo;
    ) > /tmp/setup-n8n-211-webhook.sh;



# MCP (webhook)
#====================================================================================================

    # Script do editor
    (
        echo '#!/bin/sh'
        echo
        echo "echo 'Parando: $MCPSERVER_NAME';";
        echo "docker stop $MCPSERVER_NAME 2>/dev/null;"
        echo "docker rm   $MCPSERVER_NAME 2>/dev/null;"
        echo
        echo "echo 'Iniciando: $MCPSERVER_NAME';";
        echo "docker run \\"
        echo "    -d --restart=always \\";
        echo "    --name $MCPSERVER_NAME -h $MCPSERVER_NAME.intranet.br \\";
        echo "    \\";

        echo "    --network network_public \\"
        echo "    --ip=10.117.211.3 \\"
        echo "    --ip6=2001:db8:10:117::211:3 \\"
        echo "    --mac-address '02:cd:f2:11:00:03' \\";
        echo "    \\";

        cat /tmp/setup-n8n-211-01-defaults.txt;
        cat /tmp/setup-n8n-211-02-common.txt;
        cat /tmp/setup-n8n-211-03-smtp.txt;
        cat /tmp/setup-n8n-211-04-external.txt;
        cat /tmp/setup-n8n-211-05-exec.txt;
        cat /tmp/setup-n8n-211-06-database.txt;
        cat /tmp/setup-n8n-211-07-editor.txt;
        cat /tmp/setup-n8n-211-08-redis.txt;
        cat /tmp/setup-n8n-211-10-runners.txt;
        echo "    \\";

        echo "    --mount type=bind,source=$DATADIR,destination=/home/node/.n8n,readonly=false \\";
        echo "    --mount type=bind,source=$NODEDIR,destination=/data/nodes,readonly=false \\";
        echo "    \\";

        echo "    --label \"traefik.enable=true\" \\"
        echo "    --label \"traefik.http.routers.$MCPSERVER_NAME.rule=Host(\\\`$FQDN_MCP\\\`) && PathPrefix(\\\`/mcp\\\`)\" \\";
        echo "    --label \"traefik.http.routers.$MCPSERVER_NAME.entrypoints=web,websecure\" \\";
        echo "    --label \"traefik.http.routers.$MCPSERVER_NAME.service=$MCPSERVER_NAME\" \\";
        echo "    --label \"traefik.http.routers.$MCPSERVER_NAME.tls=true\" \\";
        echo "    --label \"traefik.http.routers.$MCPSERVER_NAME.tls.certresolver=letsencrypt\" \\";
        echo "    --label \"traefik.http.services.$MCPSERVER_NAME.loadbalancer.server.port=5678\" \\";
        \
        # echo "    --label \"traefik.http.services.$MCPSERVER_NAME.middlewares=$MCPSERVER_NAME-remove-encoding\" \\";
        # echo "    --label \"traefik.http.middlewares.$MCPSERVER_NAME-remove-encoding.headers.customresponseheaders.Content-Encoding=\" \\";
        \
        echo "    \\";
        echo "    $N8N_IMAGE webhook"; # < roda o mesmo servico do webhook
        echo;
    ) > /tmp/setup-n8n-211-mcp-server.sh;

    # Content-Encoding vazio bugou o webhook
    # --label "traefik.http.routers.minha-app.middlewares=no-compression" \
    # --label "traefik.http.middlewares.no-compression.headers.customrequestheaders.Accept-Encoding=identity" \
    # Accept-Encoding: identity


# WORKERS
#====================================================================================================

    # Contar quantidade de nucleos
    CORE_COUNT=$(nproc 2>/dev/null || echo 8);
    THREADS=$(($CORE_COUNT*2));

    # Script do editor
    (
        echo '#!/bin/sh';
        echo;
        echo "echo 'Parando: $WORKER_NAME';";
        echo "docker stop $WORKER_NAME 2>/dev/null;";
        echo "docker rm   $WORKER_NAME 2>/dev/null;";
        echo;
        echo "echo 'Iniciando: $WORKER_NAME';";
        echo "docker run \\";
        echo "    -d --restart=always \\";
        echo "    --name $WORKER_NAME -h $WORKER_NAME.intranet.br \\";
        echo "    \\";

        echo "    --network network_public \\"
        echo "    --ip=10.117.211.11 \\"
        echo "    --ip6=2001:db8:10:117::211:11 \\"
        echo "    --mac-address '02:cd:f2:11:00:11' \\";
        echo "    \\";

        cat /tmp/setup-n8n-211-01-defaults.txt;
        cat /tmp/setup-n8n-211-02-common.txt;
        cat /tmp/setup-n8n-211-03-smtp.txt;
        cat /tmp/setup-n8n-211-04-external.txt;
        cat /tmp/setup-n8n-211-05-exec.txt;
        cat /tmp/setup-n8n-211-06-database.txt;
        cat /tmp/setup-n8n-211-07-editor.txt;
        cat /tmp/setup-n8n-211-08-redis.txt;
        cat /tmp/setup-n8n-211-10-runners.txt;
        echo "    \\";

        echo "    --mount type=bind,source=$DATADIR,destination=/home/node/.n8n,readonly=false \\";
        echo "    --mount type=bind,source=$NODEDIR,destination=/data/nodes,readonly=false \\";
        echo "    \\";
        echo "    $N8N_IMAGE worker --concurrency=$THREADS";
        echo;
    ) > /tmp/setup-n8n-211-worker.sh;


# Rodar tudo
#====================================================================================================

    docker rm -f n8n-editor 2>/dev/null;
    sh /tmp/setup-n8n-211-editor.sh;

    docker rm -f n8n-webhook 2>/dev/null;
    sh /tmp/setup-n8n-211-webhook.sh

    docker rm -f n8n-mcp-server 2>/dev/null;
    sh /tmp/setup-n8n-211-mcp-server.sh;

    docker rm -f n8n-worker 2>/dev/null;
    sh /tmp/setup-n8n-211-worker.sh;


exit 0;



# Preparar postgres
#---------------------------------------------------------------------------------

    docker exec -it --user postgres postgres-18 psql -U postgres;

    -- usuario do container local:
    CREATE USER n8n211
        WITH PASSWORD 'tulipasql'
            CREATEDB
            LOGIN;

    -- criar db e usuario do n8n
    CREATE DATABASE n8n211
        WITH 
        OWNER = n8n211
            ENCODING = 'UTF8'
            TABLESPACE = pg_default
            IS_TEMPLATE = False
            CONNECTION LIMIT = -1;

    -- Conectar no banco:
    \c n8n211;

    -- Sair
    \q


#---------------------------------------------------------------------------------

