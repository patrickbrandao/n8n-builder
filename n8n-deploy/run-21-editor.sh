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
