#!/bin/bash

# Upar imagens para storage
    # Incluir funcoes e variaveis
    . $(dirname $(readlink -f "$0"))/00-lib.sh;

    # Iniciando
    _echo_title "Fazendo upload dos arquivos OCI, n8n $N8N_VERSION, release $RELEASE";

    # docker pull, rsync/scp, coloque aqui

    _echo_task "Upload concluido.";
    echo;


exit 0;

