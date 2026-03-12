# N8N v2 Deploy

## Arquivos ENV
### /root/n8n-deploy/.env-n8n-core

```env
N8N_RUNNERS_MODE=external
EXECUTIONS_DATA_SAVE_ON_PROGRESS=true
EXECUTIONS_DATA_SAVE_ON_SUCCESS=all
```

### /root/n8n-deploy/.env-n8n-editor

```env
N8N_EDITOR_BASE_URL=https://n8n.seudominio.com.br/
N8N_VERSION_NOTIFICATIONS_ENABLED=false
N8N_VERSION_NOTIFICATIONS_WHATS_NEW_ENABLED=false
N8N_PUBLIC_API_SWAGGERUI_DISABLED=true
OFFLOAD_MANUAL_EXECUTIONS_TO_WORKERS=true

```

### /root/n8n-deploy/.env-n8n-global

```env
GENERIC_TIMEZONE=America/Sao_Paulo
TZ=America/Sao_Paulo
```

### /root/n8n-deploy/.env-n8n-postgres

```env
DB_TYPE=postgresdb
DB_POSTGRESDB_HOST=n8n-pgsql
DB_POSTGRESDB_PASSWORD=tulipasql
```

### /root/n8n-deploy/.env-n8n-queue

```env
EXECUTIONS_MODE=queue
EXECUTIONS_TIMEOUT=1800
```

### /root/n8n-deploy/.env-n8n-redis

```env
QUEUE_BULL_REDIS_HOST=n8n-redis
```

### /root/n8n-deploy/.env-n8n-runner

```env
N8N_RUNNERS_TASK_BROKER_URI=http://n8n-worker:5679
N8N_RUNNERS_MAX_CONCURRENCY=128=128
```

### /root/n8n-deploy/.env-n8n-services

```env
N8N_ENCRYPTION_KEY=tulipa
NODE_ENV=production
N8N_DIAGNOSTICS_ENABLED=false
N8N_USER_FOLDER=/data
N8N_METRICS=true
```

### /root/n8n-deploy/.env-n8n-tasks

```env
N8N_RUNNERS_AUTH_TOKEN=tulipa
```

### /root/n8n-deploy/.env-n8n-web

```env
WEBHOOK_URL=https://ws.seudominio.com.br/
N8N_HOST=n8n.seudominio.com.br
N8N_PROTOCOL=https
N8N_PROXY_HOPS=1
```

### /root/n8n-deploy/.env-n8n-worker

```env
N8N_RUNNERS_BROKER_LISTEN_ADDRESS=0.0.0.0
N8N_RUNNERS_ENABLED=true
```


## Scripts
### /root/n8n-deploy/run-01-network-public.sh

```bash
docker network create \
    -d bridge \
    \
    -o "com.docker.network.bridge.name"="br-net-public" \
    -o "com.docker.network.bridge.enable_icc"="true" \
    -o "com.docker.network.driver.mtu"="1500" \
    \
    --subnet 10.249.0.0/16 --gateway 10.249.255.254 \
    \
    network_public;
```

### /root/n8n-deploy/run-02-traefic-app.sh

```bash
# Email de contato para o certificado LetsEncrypt:
    EMAIL="voce@seudominio.com.br";
    [ -f /etc/email ] && EMAIL=$(head -1 /etc/email);

# Imagem do traefik, baixar atualizada:
    docker pull traefik:latest;

# Diretorio de dados persistentes:
    mkdir -p /storage/traefik-app/letsencrypt;
    mkdir -p /storage/traefik-app/logs;
    mkdir -p /storage/traefik-app/config;

# Renovar/rodar:
  docker rm -f traefik-app 2>/dev/null;
  docker run \
    -d --restart=always \
    --name traefik-app -h traefik-app.intranet.br \
    --tmpfs /run:rw,noexec,nosuid,size=8m \
    --tmpfs /tmp:rw,noexec,nosuid,size=8m \
    --read-only \
    --cpus="8.0" --memory=4g --memory-swap=4g \
    \
    --network network_public \
    \
    -p 80:80 \
    -p 443:443 \
    \
    -v /var/run/docker.sock:/var/run/docker.sock:ro \
    -v /storage/traefik-app/letsencrypt:/etc/letsencrypt \
    -v /storage/traefik-app/config:/etc/traefik \
    -v /storage/traefik-app/logs:/logs \
    \
    traefik:latest \
      \
      --global.checkNewVersion=false \
      --global.sendAnonymousUsage=false \
      \
      --api.insecure=true \
      \
      --log.level=INFO \
      --log.filePath=/logs/error.log \
      \
      --accessLog.filePath=/logs/access.log \
      \
      --entrypoints.web.address=:80 \
      --entrypoints.web.http.redirections.entryPoint.to=websecure \
      --entrypoints.web.http.redirections.entryPoint.scheme=https \
      --entrypoints.web.http.redirections.entryPoint.permanent=true \
      --entrypoints.websecure.address=:443 \
      \
      --providers.docker=true \
      --providers.file.directory=/etc/traefik \
      \
      --certificatesresolvers.letsencrypt.acme.email=$EMAIL \
      --certificatesresolvers.letsencrypt.acme.storage=/etc/letsencrypt/acme.json \
      --certificatesresolvers.letsencrypt.acme.httpchallenge.entrypoint=web;
```

### /root/n8n-deploy/run-03-n8n-postgresql.sh

```bash
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
```

### /root/n8n-deploy/run-04-n8n-redis.sh

```bash
# Pasta de persistencia RDB e AOF:
    mkdir -p /storage/n8n-redis;
    chown -R 999:999 /storage/n8n-redis;

# Baixar imagem atualizada do Redis (https://hub.docker.com/_/redis):
    docker pull redis:latest;

# Remover container atual:
    docker rm -f n8n-redis 2>/dev/null;
    
# Criar container do redis:
    docker run \
        -d --restart=always \
        --name n8n-redis -h n8n-redis.intranet.br \
        --read-only --cpus="1.0" --memory=1g --memory-swap=1g \
        \
        --network network_public \
        \
        -v /storage/n8n-redis:/data \
        -w /data \
        \
        --health-cmd="redis-cli ping" \
        --health-interval=1s \
        --health-timeout=3s \
        \
        redis:latest \
            redis-server \
                --tcp-backlog 8192 --tcp-keepalive 30 --timeout 0 \
                --dir /data --save 16 1 --save 12 10 --save  6 100 \
                --rdbcompression no --appendonly yes --appendfsync everysec;
```

### /root/n8n-deploy/run-11-datadir.sh

```bash
# Pasta para volume dos containers
    mkdir -p /storage/n8n-app;
    mkdir -p /storage/n8n-app/editor;
    mkdir -p /storage/n8n-app/worker;
    mkdir -p /storage/n8n-app/webhook;
    mkdir -p /storage/n8n-app/runner;

# Corrigir permissoes:
    chown -R 1000:1000 /storage/n8n-app;

```

### /root/n8n-deploy/run-12-pull-image.sh

```bash
# Baixar imagem docker do N8N
    docker pull docker.n8n.io/n8nio/n8n:2.11.3;

# Baixar imagem docker do Runner
    docker pull n8nio/runners:2.11.3;
```

### /root/n8n-deploy/run-21-editor.sh

```bash
# Nome de DNS para acesso HTTPs
    # - Importar da variavel N8N_HOST no arquivo .env
    . /root/n8n-deploy/.env-n8n-web;

# Remover container atual:
    docker rm -f n8n-editor 2>/dev/null;
  
# Rodando:
    docker run -d \
        --name n8n-editor -h n8n-editor.intranet.br \
        --cpus=4 --memory=4g --memory-swap=4g --shm-size=1g \
        --tmpfs /run:rw,noexec,nosuid,size=512m \
        --tmpfs /tmp:rw,noexec,nosuid,size=512m \
        \
        --network network_public \
        \
        --env-file /root/n8n-deploy/.env-n8n-global \
        --env-file /root/n8n-deploy/.env-n8n-queue \
        --env-file /root/n8n-deploy/.env-n8n-redis \
        --env-file /root/n8n-deploy/.env-n8n-postgres \
        --env-file /root/n8n-deploy/.env-n8n-services \
        \
        --env-file /root/n8n-deploy/.env-n8n-editor \
        --env-file /root/n8n-deploy/.env-n8n-web \
        --env-file /root/n8n-deploy/.env-n8n-core \
        --env-file /root/n8n-deploy/.env-n8n-tasks \
        \
        -v /storage/n8n-app/editor:/data \
        \
        --label "traefik.enable=true" \
        --label "traefik.http.routers.n8n-editor.rule=Host(\`$N8N_HOST\`)" \
        --label "traefik.http.routers.n8n-editor.entrypoints=web,websecure" \
        --label "traefik.http.routers.n8n-editor.tls=true" \
        --label "traefik.http.routers.n8n-editor.tls.certresolver=letsencrypt" \
        --label "traefik.http.services.n8n-editor.loadbalancer.server.port=5678" \
        \
        docker.n8n.io/n8nio/n8n:2.11.3;
```

### /root/n8n-deploy/run-22-webhook.sh

```bash
# Nome de DNS para acesso HTTPs
    # - Importar da variavel N8N_HOST no arquivo .env
    . /root/n8n-deploy/.env-n8n-web;
    FQDN_WEBHOOK=$(echo $WEBHOOK_URL | cut -f3 -d/);

# Remover container atual:
    docker rm -f n8n-webhook 2>/dev/null;

# Rodando:
    docker run -d \
        --name n8n-webhook -h n8n-webhook.intranet.br \
        --cpus=4 --memory=4g --memory-swap=4g --shm-size=1g \
        --tmpfs /run:rw,noexec,nosuid,size=512m \
        --tmpfs /tmp:rw,noexec,nosuid,size=512m \
        \
        --network network_public \
        \
        --env-file /root/n8n-deploy/.env-n8n-global \
        --env-file /root/n8n-deploy/.env-n8n-queue \
        --env-file /root/n8n-deploy/.env-n8n-redis \
        --env-file /root/n8n-deploy/.env-n8n-postgres \
        --env-file /root/n8n-deploy/.env-n8n-services \
        \
        --env-file /root/n8n-deploy/.env-n8n-web \
        \
        -v /storage/n8n-app/webhook:/data \
        \
        --label "traefik.enable=true" \
        --label "traefik.http.routers.n8n-webhook.rule=Host(\`$FQDN_WEBHOOK\`)" \
        --label "traefik.http.routers.n8n-webhook.entrypoints=web,websecure" \
        --label "traefik.http.routers.n8n-webhook.tls=true" \
        --label "traefik.http.routers.n8n-webhook.tls.certresolver=letsencrypt" \
        --label "traefik.http.services.n8n-webhook.loadbalancer.server.port=5678" \
        \
        docker.n8n.io/n8nio/n8n:2.11.3 webhook;

```

### /root/n8n-deploy/run-23-worker.sh

```bash
# Remover container atual:
    docker rm -f n8n-worker 2>/dev/null;

# Rodando:
    docker run -d \
        --name n8n-worker -h n8n-worker.intranet.br \
        --cpus=4 --memory=4g --memory-swap=4g --shm-size=1g \
        --tmpfs /run:rw,noexec,nosuid,size=512m \
        --tmpfs /tmp:rw,noexec,nosuid,size=512m \
        \
        --network network_public \
        \
        --env-file /root/n8n-deploy/.env-n8n-global \
        --env-file /root/n8n-deploy/.env-n8n-queue \
        --env-file /root/n8n-deploy/.env-n8n-redis \
        --env-file /root/n8n-deploy/.env-n8n-postgres \
        --env-file /root/n8n-deploy/.env-n8n-services \
        \
        --env-file /root/n8n-deploy/.env-n8n-core \
        --env-file /root/n8n-deploy/.env-n8n-worker \
        --env-file /root/n8n-deploy/.env-n8n-tasks \
        \
        -v /storage/n8n-app/worker:/data \
        \
        docker.n8n.io/n8nio/n8n:2.11.3 worker;
```

### /root/n8n-deploy/run-24-runner.sh

```bash
# Remover container atual:
    docker rm -f n8n-runner 2>/dev/null;

# Rodando:
    docker run -d \
        --name n8n-runner -h n8n-runner.intranet.br \
        --cpus=4 --memory=4g --memory-swap=4g --shm-size=1g \
        --tmpfs /run:rw,noexec,nosuid,size=512m \
        --tmpfs /tmp:rw,noexec,nosuid,size=512m \
        \
        --network network_public \
        \
        --env-file /root/n8n-deploy/.env-n8n-global \
        \
        --env-file /root/n8n-deploy/.env-n8n-runner \
        --env-file /root/n8n-deploy/.env-n8n-tasks \
        \
        -v /storage/n8n-app/runner:/data \
        \
         n8nio/runners:2.11.3;
```

### /root/n8n-deploy/run-51-setup-admin.sh

```bash
# Nome de DNS para acesso HTTPs
    # - Importar da variavel N8N_HOST no arquivo .env
    . /root/n8n-deploy/.env-n8n-web;

# Dados do formulario
    # Template JSON
    JSON_DATA='{
        "email": "admin@acme.com",
        "firstName": "Acme",
        "lastName": "Jobs",
        "password": "Acme@123"
    }';

    echo "# Definir login administrativo:";
    echo;
    echo "# URL: https://$N8N_HOST/rest/owner/setup";
    echo;
    echo "$JSON_DATA";
    echo;

    curl --insecure \
        -X POST \
        -H 'Accept: application/json, text/plain, */*' \
        -H 'Content-Type: application/json' \
        -d "$JSON_DATA" \
        "https://$N8N_HOST/rest/owner/setup";
```


