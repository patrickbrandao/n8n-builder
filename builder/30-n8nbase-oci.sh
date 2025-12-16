#!/bin/bash

# Construir imagem Docker para base de compilacao

    # Incluir funcoes e variaveis
    . $(dirname $(readlink -f "$0"))/00-lib.sh;

    _echo_title "Construindo imagem base de compilacao";

    # Entrar no diretorio dos fontes:
    _cdfolder /opt/homebrew/n8n-current;

    # Versao do container de nodejs (alpine + nodejs 22+)
    [ -f "docker/images/n8n-base/Dockerfile" ] || _abort "Arquivo n8n-base/Dockerfile nao encontrado" 22;


    # Criando nova imagem base
    _echo_task "Imagem publica: $BASE_PUBLIC_IMAGE Node Version: $NODE_VERSION";
    _echo_task "Imagem local..: $BASE_IMAGE";
    _echo_task "         Tag 1: $BASE_TAG1";
    _echo_task "         Tag 2: $BASE_TAG2";

    # Conferir se ja foi compilado recente
    FILE_FLAG_IMGNAME="/tmp/.n8n-base-$RELEASE-$BASE_NODE_VERSION-image";
    [ -f "$FILE_FLAG_IMGNAME" ] && {
        _echo_task "Imagem pronta localmente, flag de cache: $FILE_FLAG_IMGNAME";
        exit 0;
    };


    # Remover tag da ultima imagem
    _echo_task "Apagando imagem $BASE_IMAGE tag $BASE_TAG1";
    docker rmi "$BASE_TAG1" 2>/dev/null;

    _echo_task "Apagando imagem $BASE_IMAGE tag $BASE_TAG2";
    docker rmi "$BASE_TAG2" 2>/dev/null;


    # - Patch do Dockerfile do n8n-base
    # > nao remover comando APK do Alpine
    BCKEXT="orig";
    TARGET="./docker/images/n8n-base/Dockerfile";
    _backup "$TARGET";
    sed -i $SEDARG "s/apk del apk-tools/true/" "$TARGET";
    _sed_diff;


    # - Construir imagem do N8N
    _echo_task "Construindo nova imagem base: $BASE_IMAGE";
    CMD="docker build -f docker/images/n8n-base/Dockerfile . -t $BASE_TAG1 -t $BASE_TAG2;"
    _echo_exec "$CMD";
    eval "$CMD"; build_stdno="$?";

    BASE_FINAL_IMAGE="";
    if [ "$build_stdno" = "0" ]; then
        # funcionou, usar imagem local
        _echo_task "Imagem base pronta, tags: $BASE_TAG1, $BASE_TAG2";
        BASE_IMAGE="$BASE_IMAGE:$BASE_TAG2";
        # marcar flag de cache
        BASE_FINAL_IMAGE="$BASE_TAG2";
    else
        # nao funcionou, usar imagem oficial
        _echo_warn "Construcao falhou, alternando para imagem base oficial";
        BASE_FINAL_IMAGE="$BASE_PUBLIC_IMAGE";
    fi;

    # Nome da imagem base a ser utilizada
    echo "$BASE_FINAL_IMAGE" > $FILE_FLAG_IMGNAME;

    _echo_task "Imagem base selecionada: $BASE_FINAL_IMAGE";
    _echo_task "Gravando tag [$BASE_FINAL_IMAGE] em [$FILE_FLAG_IMGNAME]";

    echo;


exit 0;


# Analise de imagem oficial e imagem local
# Privada:  n8n-base-private:22.21.1
# Publica:  n8nio/base:22.21.1

    # Apagar
    undocker base-private-test;
    undocker base-public-test;

    # Rodando container comparativo privado
    docker run \
        --rm \
        -d \
        --name base-private-test \
        -h base-private-test.intranet.br \
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
        n8n-base-private:22.21.1 sleep 86400;


    # Rodando container comparativo publico
    docker run \
        --rm \
        -d \
        --name base-public-test \
        -h base-public-test.intranet.br \
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
        n8nio/base:22.21.1 sleep 86400;
















