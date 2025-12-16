#!/bin/sh

# Limpar diretorio de trabalho do n8n antigo
    # Incluir funcoes e variaveis
    . $(dirname $(readlink -f "$0"))/00-lib.sh;

    _echo_title "Limpando diretorio de trabalho";

    # remover atual
    _echo_task "Removendo container de base (se existir)";
    docker rm -f n8nio-base 2>/dev/null;

    # Diretorio para rodar o programa: /opt/homebrew/n8n-current
    _echo_task "Limpando diretorio: /opt/homebrew/n8n-current";
    rm -rf /opt/homebrew/n8n-current  2>/dev/null;
    rm -rf /opt/homebrew/n8n-*        2>/dev/null;
    rm -rf /opt/homebrew/.pnpm-store  2>/dev/null;
    rm -rf /opt/homebrew/tmp          2>/dev/null;

    # Remover cache
    rm -f /tmp/.n8n* 2>/dev/null;
    rm -f /tmp/.node* 2>/dev/null;
    rm -f /tmp/.pnpm* 2>/dev/null;
    rm -f /tmp/.runner* 2>/dev/null;

    echo;

exit 0;
