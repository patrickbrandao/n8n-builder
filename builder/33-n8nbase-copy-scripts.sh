#!/bin/bash

# Copiar scripts para pasta dos fontes para executa-los dentro do container mais adiante

    # Incluir funcoes e variaveis
    . $(dirname $(readlink -f "$0"))/00-lib.sh;

    _echo_title "Copiar scripts para dentro da pasta de fontes (/opt/homebrew/n8n-current/scripts/)";

    # Entrar no diretorio dos fontes:
    _cdfolder /opt/homebrew/n8n-current;

    # Copiar scripts para dentro dos fontes
    _echo_task 'Copiando scripts'
    _echo_cmd ' Origem..: /root/n8n-builder/scripts/';
    _echo_cmd ' Destino.: /opt/homebrew/n8n-current/scripts/';
    mkdir -p /opt/homebrew/n8n-current/scripts;
    cp -rav /root/n8n-builder/scripts/* /opt/homebrew/n8n-current/scripts/;
    echo;


exit 0;

