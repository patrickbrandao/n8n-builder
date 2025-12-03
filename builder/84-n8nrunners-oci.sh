#!/bin/bash

# Construir imagem Docker para base de compilacao
    # Incluir funcoes e variaveis
    . $(dirname $(readlink -f "$0"))/00-lib.sh;

    _echo_title "Construindo imagem de runners";

    # Entrar no diretorio dos fontes:
    _cdfolder /opt/homebrew/n8n-current;


    # Tipo de imagem
    RUNNERS_TYPE="default";
    DOCKERFILE="docker/images/runners/Dockerfile";
    [ "$1" = "distroless" ] && {
        DOCKERFILE="docker/images/runners/Dockerfile.distroless";
        RUNNERS_TYPE="distroless";
    };
    # Arquivo para produzir nome da imagem
    ROCI_CACHE="/tmp/.n8n-runners-image-${RELEASE}-${RUNNERS_TYPE}-${N8N_VERSION}";


    # Versao do container de nodejs (alpine + nodejs 22+)
    [ -f "$DOCKERFILE" ] || _abort "Arquivo $DOCKERFILE nao encontrado" 22;


    # Criando nova imagem base
    RUNNERS_IMAGE="n8n-runners-${RELEASE}-${RUNNERS_TYPE}";
    RUNNERS_TAG1="$RUNNERS_IMAGE:latest";
    RUNNERS_TAG2="$RUNNERS_IMAGE:${N8N_VERSION}";


    echo;
    _echo_task "Runners - release.............: $RELEASE";
    _echo_task "Runners - versao do N8N.......: $N8N_VERSION";
    _echo_task "Runners - versao do Python....: $RUNNERS_PYTHON_VERSION";
    _echo_task "Runners - versao do NodeJS....: $RUNNERS_NODE_VERSION";
    echo;
    _echo_task "Runners - Imagem publica......: $PUBLIC_IMAGE";
    _echo_task "Runners - image local.........: $RUNNERS_IMAGE";
    _echo_task "Runners - Imagem local (tags).: $RUNNERS_TAG1, $RUNNERS_TAG2";
    _echo_task "Runners - Dockerfile local....: $DOCKERFILE";
    echo;


    # Conferir se ja foi compilado recente
    [ -f "$ROCI_CACHE" ] && {
        _echo_task "Imagem pronta localmente, flag de cache: $ROCI_CACHE";
        exit 0;
    };


    # Remover tag da ultima imagem
    _echo_task "Apagando tag $RUNNERS_TAG1";
    _echo_exec "docker rmi $RUNNERS_TAG1";
    docker rmi "$RUNNERS_TAG1" 2>/dev/null;


    # - Construir imagem do N8N
    _echo_task "Construindo nova imagem runners: $RUNNERS_IMAGE";
    _echo_exec "docker build -f $DOCKERFILE . -t $RUNNERS_TAG1 -t $RUNNERS_TAG2";
    docker build \
        -f $DOCKERFILE . \
        -t $RUNNERS_TAG1 \
        -t $RUNNERS_TAG2;
    build_stdno="$?";


    # Conferir resultado da compilacao
    if [ "$build_stdno" = "0" ]; then
        # funcionou, usar imagem local
        _echo_task "Imagem runners pronta, tags: $RUNNERS_TAG1, $RUNNERS_TAG2";
        RUNNERS_IMAGE="$RUNNERS_TAG2";

        # salvar nome da imagem
        _echo_task "Nome da imagem pronta: $RUNNERS_IMAGE";
        echo "$RUNNERS_IMAGE" > $ROCI_CACHE;
    else
        # nao funcionou, usar imagem oficial
        _abort "Construcao falhou, alternando para imagem runners oficial ($PUBLIC_IMAGE)";
    fi;

    echo;



exit 0;


