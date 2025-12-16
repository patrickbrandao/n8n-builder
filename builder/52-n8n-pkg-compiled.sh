#!/bin/bash

# Empacotar pasta ./compiled
    # Incluir funcoes e variaveis
    . $(dirname $(readlink -f "$0"))/00-lib.sh;

    _echo_title "Empacotando N8N (./compiled)";

    # Entrar no diretorio dos fontes:
    _cdfolder /opt/homebrew/n8n-current;

    # Argumento
    # - release
    set_release="$1";
    [ "x$set_release" = "x" ] || RELEASE="$set_release";

    # Sufixo do arquivo
    if [ "$RELEASE" = "private" ]; then
        _echo_task "Imagem privada";
    else
        _echo_task "Imagem publica aberta";
    fi;

    # Gerar pacote da pasta 'compiled'
    COMPILED_PKG="/root/n8n-${N8N_VERSION}-$RELEASE-compiled.tgz";
    CMD="tar -cpzf "$COMPILED_PKG" ./compiled";
    _echo_task "Empacotando app compilado (pasta ./compiled, pwd $PWD) em: $COMPILED_PKG";
    _echo_exec "$CMD";
    $CMD || _abort "Erro $? ao comprimir compiled: $CMD" 52;

    _echo_task "Pacote compiled pronto: $COMPILED_PKG";
    echo;

exit 0;

