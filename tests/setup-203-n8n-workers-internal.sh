#!/bin/bash

# n8n
#   - single main, single worker, postgres database
#   - worker: 1
#   - runners: desativado, modo internal no worker

# Funcoes
    _echo_title(){ echo; printf "\033[33;7m > \033[0m\033[32;7m $1 \033[0m\n"; };

# Variaveis
    NAME="n8n-203-single-sqlite-wi";
    LOCAL="$NAME.intranet.br";

    WORKER="n8n-203-worker";
    WLOCAL="$WORKER.intranet.br";

# Rede
    NETWORK="network_public";
    N8N_CONTAINER_MAC="02:cd:f2:03:00:01";
    N8N_CONTAINER_IPV4="10.117.203.1";
    N8N_CONTAINER_IPV6="2001:db8:10:117::203:1";

    WORKER_CONTAINER_MAC="02:cd:f2:03:00:02";
    WORKER_CONTAINER_IPV4="10.117.203.2";
    WORKER_CONTAINER_IPV6="2001:db8:10:117::203:2";


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
        -p 10203:5678 \
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
        -e QUEUE_BULL_REDIS_DB=203 \
        -e QUEUE_BULL_PREFIX=bull203 \
        -e QUEUE_HEALTH_CHECK_ACTIVE=true \
        \
        -e N8N_CONCURRENCY_PRODUCTION_LIMIT=10 \
        \
        -e DB_TYPE=postgresdb \
        -e DB_POSTGRESDB_HOST=postgres-18 \
        -e DB_POSTGRESDB_PORT=5432 \
        -e DB_POSTGRESDB_USER=n8n203 \
        -e DB_POSTGRESDB_PASSWORD=tulipasql \
        -e DB_POSTGRESDB_DATABASE=n8n203 \
        -e DB_POSTGRESDB_SCHEMA=public \
        \
        -e N8N_METRICS=true \
        \
        -e N8N_SECURE_COOKIE=false \
        -e N8N_SAMESITE_COOKIE=n8n203 \
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
        -e QUEUE_BULL_REDIS_DB=203 \
        -e QUEUE_HEALTH_CHECK_ACTIVE=true \
        \
        -e N8N_CONCURRENCY_PRODUCTION_LIMIT=10 \
        \
        -e DB_TYPE=postgresdb \
        -e DB_POSTGRESDB_HOST=postgres-18 \
        -e DB_POSTGRESDB_PORT=5432 \
        -e DB_POSTGRESDB_USER=n8n203 \
        -e DB_POSTGRESDB_PASSWORD=tulipasql \
        -e DB_POSTGRESDB_DATABASE=n8n203 \
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
    CREATE USER n8n203
        WITH PASSWORD 'tulipasql'
            CREATEDB
            LOGIN;

    -- criar db e usuario do n8n
    CREATE DATABASE n8n203
        WITH 
        OWNER = n8n203
            ENCODING = 'UTF8'
            TABLESPACE = pg_default
            IS_TEMPLATE = False
            CONNECTION LIMIT = -1;

    -- Conectar no banco:
    \c n8n203;

    -- Sair
    \q


#---------------------------------------------------------------------------------

    # Listar tabelas
    docker exec -it --user postgres postgres-18 psql -d n8n203 -U postgres -c "\dt";

    # Listar projetos
    docker exec --user postgres postgres-18 psql -d n8n203 -U postgres -c "SELECT * FROM project ORDER BY id;"




#---------------------------------------------------------------------------------

    # Dados do usuario
    FIRST_NAME="Acme";
    LAST_NAME="Jobs";
    USER_EMAIL="admin@acme.com";
    USER_PASSWD="Acme@123";

    # Senha: Acme@123
    # n8n usa padrao bcrypt descontinuado
    USER_BCRYPT_PASSWD='$2a$10$mBk9VYko1q0GYf4/D0vh3O08torSyfcH48znhwe4Z3pUl2h9Aewi.'; 



    # Obter project_id
    # psql -U username -d database_name -c "SELECT * FROM my_table;"
    PROJECT_ID=$(docker exec --user postgres postgres-18 psql -d n8n203 -U postgres -t -c "SELECT id FROM project LIMIT 1;");


    echo "# Administrador..: $FIRST_NAME $LAST_NAME";
    echo "# Email (login)..: $USER_EMAIL";
    echo "# Senha..........: $USER_PASSWD";

    # Executando alteracoes

    # 1 - Preencher dados no projeto
    docker exec --user postgres postgres-18 psql -d n8n203 -U postgres -t -c \
        "UPDATE project SET name = '$FIRST_NAME $LAST_NAME <$USER_EMAIL>' WHERE id = '$PROJECT_ID';"

        # * nao atualizou, precisa investigar essa tabela

    # ** Parei aqui **

    # 2 - Marcar instancia como inicializada
    sqlite3 "$SQDB" "UPDATE settings SET value = 'true' WHERE key = 'userManagement.isInstanceOwnerSetUp';"

    # 3 - Definir login
    # Obter id do usuario padrao
    USER_UUID=$(sqlite3 "$SQDB" "SELECT id FROM user LIMIT 1;");
    # Remover UUID de usuario indefinido

    # Definir dados pessoais
    sqlite3 "$SQDB" "UPDATE user SET email = '$USER_EMAIL', firstName = '$FIRST_NAME', lastName = '$LAST_NAME' WHERE id = '$USER_UUID';"

    # Definir senha
    sqlite3 "$SQDB" "UPDATE user SET password = '$USER_BCRYPT_PASSWD' WHERE id = '$USER_UUID';"

    # Definir data de ativacao
    TODAY=$(date '+%Y-%m-%d');
    NOWDT=$(date '+%Y-%m-%d-%H%M');
    sqlite3 "$SQDB" "UPDATE user SET lastActiveAt = '$TODAY', updatedAt = $NOWDT WHERE id = '$USER_UUID';"


    _echo_lighcyan "# Concluido.";
    echo;




# Definir senha no primeiro setup (postgres)


# Acessando:
    # - obter nome do servidor:
    SERVER=$(hostname -f);
    PORT=48022;
    ssh -N root@$SERVER -p $PORT -L 127.0.0.1:10203:10.117.203.1:5678

    # http://localhost:10203/

# Destruir container e iniciar do zero
    docker rm -f n8n-203-single-sqlite-wi;
    rm  -rf /storage/n8n-203-single-sqlite-wi;
    sh /root/n8n-builder/test-server/setup-203-n8n-workers-internal.sh;








