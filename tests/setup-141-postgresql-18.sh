#!/bin/bash

# Variaveis
    NAME=postgres-18;
    LOCAL=$NAME.intranet.br;

    # Argumentos do postgres
    POSTGRES_USER="postgres";
    POSTGRES_PASSWORD="tulipasql";
    POSTGRES_DB="n8n";

# Imagem (postgres:16.4, postgres:18)
    IMAGE=postgres:18;
    docker pull $IMAGE;

# Volume
    DATADIR=/storage/$NAME;
    mkdir -p $DATADIR;
    chown -R 999:999 $DATADIR;

# Renovar/rodar:
    ( docker stop $NAME; docker rm $NAME; sync && sleep 1; ) 2>/dev/null;
    docker run \
        -d --restart=always \
        --name $NAME -h $LOCAL \
        \
        --network network_public \
        --ip=10.117.141.1 \
        --ip6=2001:db8:10:117::141:1 \
        --mac-address "02:cd:f1:41:00:01" \
        \
        -v $DATADIR:/var/lib/postgresql/data \
        \
        -e POSTGRES_USER=$POSTGRES_USER \
        -e POSTGRES_PASSWORD=$POSTGRES_PASSWORD \
        -e POSTGRES_DB=$POSTGRES_DB \
        -e PGDATA=/var/lib/postgresql/data/pgdata \
        \
        --health-cmd="pg_isready -U postgres" \
        --health-interval=5s \
        --health-timeout=5s \
        --health-retries=10 \
        \
        $IMAGE \
			postgres --max_connections=1024;

exit;

# Banco de dados para testes
    docker exec -it --user postgres postgres-18 psql -U postgres;

    -- usuario do container local:
    CREATE USER debv
        WITH PASSWORD 'tulipasql'
            CREATEDB
            LOGIN;

    -- criar db e usuario do n8n
    CREATE DATABASE debv
        WITH 
        OWNER = debv
            ENCODING = 'UTF8'
            TABLESPACE = pg_default
            IS_TEMPLATE = False
            CONNECTION LIMIT = -1;

    -- Conectar no banco:
    \c debv;

    -- Sair
    \q









