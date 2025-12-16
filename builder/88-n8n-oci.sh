#!/bin/bash

# N8N - Fazer build principal
    # Incluir funcoes e variaveis
    . $(dirname $(readlink -f "$0"))/00-lib.sh;

    # Iniciando
    _echo_title "Construindo imagem Docker do N8N - $N8N_IMAGE ($N8N_TAG1, $N8N_TAG2)";

    # Entrar no diretorio dos fontes:
    _cdfolder /opt/homebrew/n8n-current;


    # Conferir se ja foi compilado recente
    FLAG_DONE="/tmp/.n8n-$RELEASE-$N8N_VERSION-image-flag";
    [ -f "$FLAG_DONE" ] && {
        _echo_task "Imagem pronta localmente, flag de cache: $FLAG_DONE";
        exit 0;
    };


    # Remover imagem com a tag atual
    _echo_task "Removendo tag latest da imagem atual ($N8N_IMAGE, tags $N8N_TAG1 e $N8N_TAG2)";
    _echo_exec "docker rmi $N8N_TAG1";
    docker rmi $N8N_TAG1 2>/dev/null;
    _echo_exec "docker rmi $N8N_TAG2";
    docker rmi $N8N_TAG2 2>/dev/null;


    # - Construir imagem do N8N
    _echo_task "Construindo nova imagem $N8N_IMAGE +$N8N_TAG1 +$N8N_TAG2)";
    _echo_exec "docker build -f docker/images/n8n/Dockerfile . -t $N8N_TAG1 -t $N8N_TAG2";
    docker build \
        -f docker/images/n8n/Dockerfile . \
        -t $N8N_TAG1 \
        -t $N8N_TAG2;
    stdno="$?";

    # - Precisa passar
    if [ "$stdno" = "0" ]; then
        _echo_task "Construcao da imagem concluida."
    else
        # falhou
        _abort "Falhou ao rodar docker-build de $N8N_IMAGE" 41;
    fi;

    # nome da imagem
    echo "$N8N_TAG1" > $FLAG_DONE;


    _echo_task "Docker BUILD n8n concluido, nova imagem: $N8N_IMAGE ($N8N_TAG1, $N8N_TAG2)";
    echo;


exit 0;

