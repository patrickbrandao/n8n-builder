#!/bin/bash

# Remover container base d compilacao
    # Incluir funcoes e variaveis
    . $(dirname $(readlink -f "$0"))/00-lib.sh;

    _echo_title "Apagar containers usados na compilacao";

    # Entrar no diretorio dos fontes:
    _cdfolder /opt/homebrew/n8n-current;

    # remover atual
    _echo_task "Removendo container de base";
    CMD="docker rm -f $CONTAINER_BASE_NAME";
    _echo_exec "$CMD";
    $CMD 2>/dev/null 1>/dev/null;
    echo;


exit 0;
