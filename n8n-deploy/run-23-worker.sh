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
