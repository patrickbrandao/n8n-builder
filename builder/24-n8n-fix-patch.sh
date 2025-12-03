#!/bin/bash

# Fazer alteracoes nos fontes

    # Incluir funcoes e variaveis
    . $(dirname $(readlink -f "$0"))/00-lib.sh;

    _echo_title "Aplicando correcos no N8N";

    # Entrar no diretorio dos fontes:
    _cdfolder /opt/homebrew/n8n-current;

    # Inserir patchs e correcoes que nao sofreram commit AQUI
    # observar a versao do N8N e a versao do patch antes de aplicar


exit 0
