#!/bin/bash

# Fazer compilacao do N8N e produzir ./compiled/ (APP pronto)

    # Incluir funcoes e variaveis
    . $(dirname $(readlink -f "$0"))/00-lib.sh;

    _echo_title "Compilando projeto N8N $RELEASE $N8N_VERSION";

    # Entrar no diretorio dos fontes:
    _cdfolder /opt/homebrew/n8n-current;


    # Preparar (root)
    CMD="sh /app/scripts/build-compiled.sh";
    _echo_exec "docker exec -it --user node $CONTAINER_BASE_NAME ash -c '$CMD'";
    docker exec -it --user node $CONTAINER_BASE_NAME ash -c "$CMD;";


    # Conferir se funcionou
    [ -d /opt/homebrew/n8n-current/compiled ] || {
        _abort "COMPILACAO FALHOU, a pasta nao foi construida: /opt/homebrew/n8n-current/compiled" 31;
    };

    _echo_task "Compilacao concluida, ./compiled/ disponivel.";
    _echo_task "Diretorio: /opt/homebrew/n8n-current/compiled";
    echo;


exit 0;
