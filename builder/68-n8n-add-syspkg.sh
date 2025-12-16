#!/bin/bash

# N8N - Adicionar pacotes e recursos no container final
    # Incluir funcoes e variaveis
    . $(dirname $(readlink -f "$0"))/00-lib.sh;

    _echo_title "Adicionando pacotes na imagem do N8N";

    # Arquivo para patch
    SEDFILE="";
    _backup(){
        F="$1";
        [ -f "$F.$BCKEXT" ] || { _echo_task "BACKUP: $F -> $F.$BCKEXT"; cp $F $F.$BCKEXT; };
        [ -f "$F.$BCKEXT" ] && { _echo_task "RESET.: $F.$BCKEXT -> $F"; cp $F.$BCKEXT $F; };
        SEDFILE="$F";
    };
    _sed_diff(){ echo; echo; _echo_task "diff $SEDFILE.$BCKEXT $SEDFILE"; diff --color=always -Naur $SEDFILE.$BCKEXT $SEDFILE 2>/dev/null; echo; echo; };

    # Entrar no diretorio dos fontes:
    _cdfolder /opt/homebrew/n8n-current;


    # Versao do container de nodejs (alpine + nodejs 22+)
    DF="./docker/images/n8n/Dockerfile";
    [ -f "$DF" ] || _abort "Arquivo $DF nao encontrado" 39;

    _backup "$DF";
    sed -i '/EXPOSE 5678\/tcp/i RUN ( apk update; apk upgrade; apk add bash rsync fping tcpdump mtr nmap htop nftables net-snmp net-snmp-tools net-snmp-agent-libs supervisor python3 py3-pip iputils-arping iputils-ping apache2-utils bind-tools wireguard-tools grep sed tar zip unzip zstd gzip sshpass; true PKG01; )' $DF;
    _sed_diff;
    echo;


exit 0;
