#!/bin/bash

# Variaveis
    NAME="weavescope";
    DOMAIN="$(hostname -f)";
    FQDN="$NAME.$DOMAIN";
    LOCAL=$NAME.intranet.br;

# Imagem:
    IMAGE="weaveworks/scope:1.13.2";
    docker pull $IMAGE;

# Pasta de persistencia
    DATADIR=/storage/$NAME;
    mkdir  -p $DATADIR;

# Renovar/rodar
    docker rm -f $NAME 2>/dev/null
    docker pull $IMAGE;
    docker run \
        -d --restart=always \
        --name $NAME -h $LOCAL \
        --security-opt label=disable \
        --tmpfs /run:rw,noexec,nosuid,size=2m \
        --tmpfs /tmp:rw,noexec,nosuid,size=2m \
        --privileged \
        --cpus="2.0" --memory=1g --memory-swap=1g \
        \
        --net=host \
        --pid=host \
        --userns=host \
        \
        -v /var/run/docker.sock:/var/run/docker.sock \
        -v /sys/kernel/debug:/sys/kernel/debug \
        \
        -e CHECKPOINT_DISABLE \
        -e ENABLE_BASIC_AUTH=true \
        -e BASIC_AUTH_USERNAME=admin \
        -e BASIC_AUTH_PASSWORD=tulipa \
        \
        --label "traefik.enable=true" \
        --label "traefik.http.routers.$NAME.rule=Host(\`$FQDN\`)" \
        --label "traefik.http.routers.$NAME.entrypoints=websecure" \
        --label "traefik.http.routers.$NAME.tls=true" \
        --label "traefik.http.routers.$NAME.tls.certresolver=letsencrypt" \
        --label "traefik.http.services.$NAME.loadbalancer.server.port=4040" \
        \
        $IMAGE --probe.docker=true;

	echo;
	echo "Acesso: https://$FQDN";
	echo;

# obs: nao suporta --read-only


exit 0;


# Original:
	undocker weavescope;
	docker run -d \
		--name weavescope \
		--privileged \
		--net=host \
		--pid=host \
		--userns=host \
		--security-opt label=disable \
		-v /var/run/docker.sock:/var/run/docker.sock \
		-v /sys/kernel/debug:/sys/kernel/debug \
		-e CHECKPOINT_DISABLE \
		-e ENABLE_BASIC_AUTH=true \
		-e BASIC_AUTH_USERNAME=admin \
		-e BASIC_AUTH_PASSWORD=tulipa \
		weaveworks/scope:1.13.2 \
		--probe.docker=true;



