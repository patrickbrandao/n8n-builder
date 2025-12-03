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

