# Credenciais de acesso ao PG
    POSTGRES_USER="postgres";
    POSTGRES_PASSWORD="tulipasql";
    POSTGRES_DB="n8n";

# Pasta para o volume
    mkdir -p /storage/n8n-pgsql;
    chown -R 999:999 /storage/n8n-pgsql;

# Rodar:
    docker pull pgvector/pgvector:pg18-trixie;
    docker run \
        -d --restart=always \
        --name n8n-pgsql -h n8n-pgsql.intranet.br \
        --read-only --cpus="2.0" --memory=2g --memory-swap=2g --shm-size=1g \
        \
        --network network_public \
        \
        --tmpfs /run:rw,noexec,nosuid,size=128m \
        --tmpfs /tmp:rw,noexec,nosuid,size=128m \
        \
        -v /storage/n8n-pgsql:/var/lib/postgresql/data \
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
        --entrypoint "docker-entrypoint.sh" \
        \
        pgvector/pgvector:pg18-trixie \
            postgres \
                --max_connections=8192 \
                --wal_level=minimal \
                --max_wal_senders=0 \
                --port=5432;
