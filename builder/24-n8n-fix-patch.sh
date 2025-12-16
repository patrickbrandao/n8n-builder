#!/bin/bash

# Fazer alteracoes nos fontes

    # Incluir funcoes e variaveis
    . $(dirname $(readlink -f "$0"))/00-lib.sh;

    _echo_title "Aplicando correcos no N8N";

    # Entrar no diretorio dos fontes:
    _cdfolder /opt/homebrew/n8n-current;


    echo;


exit 0;
