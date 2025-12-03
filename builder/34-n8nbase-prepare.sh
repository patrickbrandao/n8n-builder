#!/bin/bash

# Preparar container de compilacao

    # Incluir funcoes e variaveis
    . $(dirname $(readlink -f "$0"))/00-lib.sh;

    _echo_title "Preparando container de compilacao ($CONTAINER_BASE_NAME)";

    # Entrar no diretorio dos fontes:
    _cdfolder /opt/homebrew/n8n-current;


    # Copiar scripts para dentro dos fontes
    _echo_task 'Copiando scripts'
    mkdir -p /opt/homebrew/n8n-current/scripts;
    cp -ra /root/n8n-builder/scripts/* /opt/homebrew/n8n-current/scripts/;


    # Preparar (root)
    CMD="sh /app/scripts/build-prepare-deps.sh";
    _echo_exec "docker exec -it --user root $CONTAINER_BASE_NAME ash -c '$CMD'";
    docker exec -it --user root $CONTAINER_BASE_NAME ash -c "$CMD;";


    # Instalar dependencias (node)
    CMD="sh /app/scripts/build-install-deps.sh";
    _echo_exec "docker exec -it --user root $CONTAINER_BASE_NAME ash -c '$CMD'";
    docker exec -it --user node $CONTAINER_BASE_NAME ash -c "$CMD;";
    echo;


exit 0;

