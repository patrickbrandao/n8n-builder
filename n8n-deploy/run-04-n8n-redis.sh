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
