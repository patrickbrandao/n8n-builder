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
