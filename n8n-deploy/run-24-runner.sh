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
