#!/bin/bash

# Construir container base para compilacao do N8N

    # Incluir funcoes e variaveis
    . $(dirname $(readlink -f "$0"))/00-lib.sh;

    _echo_title "Criar container para compilar N8N";


    # Entrar no diretorio dos fontes:
    _cdfolder /opt/homebrew/n8n-current;


    # Versao do container de nodejs (alpine + nodejs 22+)
    [ -f "docker/images/n8n-base/Dockerfile" ] || _abort "Arquivo n8n-base/Dockerfile nao encontrado" 22;


    # Imagem a utilizar
    FILE_FLAG_IMGNAME="/tmp/.n8n-base-$RELEASE-$BASE_NODE_VERSION-image";

    BASE_IMAGE="$BASE_PUBLIC_IMAGE";
    ctmp="";
    if [ -f "$FILE_FLAG_IMGNAME" ]; then
        ctmp=$(head -1 $FILE_FLAG_IMGNAME 2>/dev/null);
        [ "x$ctmp" = "x" ] || BASE_IMAGE="$ctmp";
    fi;

    # sem imagem em cache, usar imagem publica, baixar
    [ "$BASE_IMAGE" = "$BASE_PUBLIC_IMAGE" ] && {
        # garantir imagem publica localmente;
        _echo_task "Baixando imagem do container base ($BASE_IMAGE)";
        docker pull $BASE_IMAGE || _abort "Falhou ao obter imagem (pull) de $BASE_IMAGE" 24;
    };


    # Imagem escolhida para continuar
    _echo_task "Usando imagem: $BASE_IMAGE";


    # remover atual
    _echo_task "Removendo container anterior ($CONTAINER_BASE_NAME)...";
    docker rm -f $CONTAINER_BASE_NAME 2>/dev/null;


    # rodar:
    _echo_task "Iniciando container $BASE_IMAGE ~ n8nio-base";
    _echo_exec "docker run --rm -d --name n8nio-base --user=root --cap-add=ALL --privileged --shm-size=4g --tmpfs /run:rw,exec,size=4g -v /var/run/docker.sock:/var/run/docker.sock:ro -v /opt/homebrew/n8n-current:/app -w /app $IMAGE sleep 86400";
    docker run \
        --rm \
        -d \
        --name $CONTAINER_BASE_NAME \
        -h $CONTAINER_BASE_NAME.intranet.br \
        --user=root \
        --cap-add=ALL \
        --privileged \
        --shm-size=4g \
        --tmpfs /run:rw,exec,size=4g \
        \
        -v /var/run/docker.sock:/var/run/docker.sock:ro \
        -v /opt/homebrew/n8n-current:/app \
        \
        -w /app \
        \
        $BASE_IMAGE sleep 86400 || _abort "Falhou ao rodar container de $BASE_IMAGE" 22;

    # Shell no container
    # docker exec -it --user root n8nio-base ash

    echo;


exit 0;

