#!/bin/bash

# Prepara ambiente para compilacao do N8N no Linux

    # Incluir funcoes e variaveis
    . $(dirname $(readlink -f "$0"))/00-lib.sh;

    _echo_title "Preparativos do ambiente";

    UNAMEO=$(uname -o);
    if [ "$UNAMEO" = "GNU/Linux" ]; then

        _echo_task "Preparativos do ambiente Linux Debian";

        [ -x /usr/bin/apt ] || _abort "Linux requer ambiente debian instalado" 1;
        _abort(){ echo; echo "Erro fatal $1"; echo; exit $2; }

        # Linux
        _echo_task "Atualizando APT";

        # Atualizar apt:
        FLAG="/tmp/.flag-apt-update";
        if [ -f "$FLAG" ]; then
            _echo_task "APT atualizado previamente";
        else
            _echo_task "Atualizando apt...";
            apt -y update;
            apt -y upgrade;
            apt -y dist-upgrade;
            apt -y full-upgrade;
            date > $FLAG;
        fi;

        _echo_task "Instalando programas";
        which go      >/dev/null || apt-get -y install golang;
        which jq      >/dev/null || apt-get -y install jq;
        which pv      >/dev/null || apt-get -y install pv;
        which git     >/dev/null || apt-get -y install git;
        which pigz    >/dev/null || apt-get -y install pigz;
        which wget    >/dev/null || apt-get -y install wget;
        which curl    >/dev/null || apt-get -y install curl;
        which rsync   >/dev/null || apt-get -y install rsync;
        which python3 >/dev/null || apt-get -y install python3;
        which sqlite3 >/dev/null || apt-get -y install sqlite3;

        #- Node.js - atual: 25
        #- apt -y install node;
        # Node.js - versao 24 requerida pelo n8n
        [ -x /usr/bin/node ] || {
            curl -fsSL https://deb.nodesource.com/setup_24.x | bash -;
        };

        # Instalar Corepack (ignore erros)
        [ -x "/usr/bin/corepack" ] || {
            _echo_task "Atualizando corepack...";
            npm install -g corepack;
        };

        # Docker
        which docker >/dev/null || {
            # Baixar script instalador oficial:
            curl -fsSL get.docker.com -o /tmp/get-docker.sh;
            # Executar script instalador:
            sh /tmp/get-docker.sh;

            # Comando para parar e destruir um container:
            (
                echo '#!/bin/sh';
                echo;
                echo 'for x in $@; do';
                echo '    echo -n "Stop and delete [$1] ";';
                echo '    docker stop $x 2>/dev/null 1>/dev/null;'
                echo '    echo -n ".";';
                echo '    docker stop $x 2>/dev/null 1>/dev/null;'
                echo '    echo -n ".";';
                echo '    docker rm -f $x 2>/dev/null 1>/dev/null;'
                echo '    echo -n ".";';
                echo '    echo "OK";';
                echo 'done';
                echo;
            ) > /usr/bin/undocker;
            chmod +x /usr/bin/undocker;

            # Comando para entrar no shell (/bin/sh) de um container:
            (
                echo '#!/bin/sh';
                echo;
                echo 'docker exec --user=root -it $1 /bin/bash;';
                echo;
            ) > /usr/bin/dsh;
            chmod +x /usr/bin/dsh;

            # Comando para listar containers em execucao (inclusive parados):
            (
                echo '#!/bin/sh';
                echo;
                echo 'EXTRA="";';
                echo '[ "x$1" = "x" ] || EXTRA="-f name=$1";';
                echo 'echo;';
                echo 'docker ps -a $EXTRA;';
                echo 'echo;';
                echo;
            ) > /usr/bin/dps;
            chmod +x /usr/bin/dps;

            # Lista simples de containers (sem portas estragando a listagem)
            (
                echo '#!/bin/sh';
                echo;
                echo 'EXTRA=""';
                echo '[ "x$1" = "x" ] || EXTRA="-f name=$1";';
                echo 'CLS1="{{.ID}}\t{{.Names}}\t{{.Networks}}";';
                echo 'CLS2="\t{{.Status}}\t{{.Size}}\t{{.Image}}";';
                echo 'COLS="table $CLS1\t$CLS2";';
                echo 'echo;';
                echo 'docker ps --format "$COLS" $EXTRA;';
                echo 'echo;';
                echo;
            ) > /usr/bin/dlist;
            chmod +x /usr/bin/dlist;
        };

    else
        # nao-mac
        _echo_task "Pulando apt (nao estamos no Linux)";
    fi;

    echo;

exit 0;

