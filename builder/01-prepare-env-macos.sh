#!/bin/bash

# Prepara ambiente para compilacao do N8N no MacOS

    # Incluir funcoes e variaveis
    . $(dirname $(readlink -f "$0"))/00-lib.sh;

    _echo_title "Preparativos do ambiente";


    UNAMEO=$(uname -o);
    if [ "$UNAMEO" = "Darwin" ]; then

        _echo_task "Preparativos do ambiente MacOS";

        [ -x /opt/homebrew/bin/brew ] || _abort "MacOS requer brew (homebrew) instalado" 1;
        _abort(){ echo; echo "Erro fatal $1"; echo; exit $2; }

        # MacOS
        _echo_task "Atualizando Homebrew";

            # Atualizar brew:
            FLAG="/tmp/.flag-brew-update";
            if [ -f "$FLAG" ]; then
                _echo_task "Brew atualizado previamente";
            else
                _echo_task "Atualizando Brew...";
                brew update;
                brew upgrade;
                date > $FLAG;
            fi;

            # Colocar homebrew no PATH
            egrep -q '/opt/homebrew/bin' ~/.bash_profile 2>/dev/null || \
                /bin/echo "export PATH='/opt/homebrew/bin:$PATH';" >> ~/.bash_profile;


        _echo_task " Instalando programas";

            # sqlite3
            [ -x /usr/bin/sqlite3 -o -x /opt/homebrew/bin//opt/homebrew/bin/wget ] || brew install sqlite3;

            # wget
            [ -x /opt/homebrew/bin/wget ] || brew install wget;

            # rsync
            [ -x /opt/homebrew/bin/rsync ] || brew install rsync;

            # Uv
            [ -x /opt/homebrew/bin/uv ] || brew install uv;

            # Git
            [ -x /opt/homebrew/bin/git ] || brew install git;

            # Python (necessário para algumas dependências, v3.14)
            [ -x /opt/homebrew/bin/python3 ] || brew install python3;

            # Jq - interpretador JSON
            [ -x /opt/homebrew/bin/jq ] || brew install jq;

            # Instalar Go
            [ -x /opt/homebrew/bin/go ] || brew install go;

            #- Node.js - atual: 25
            #- brew install node;
            # Node.js - versao 24 requerida pelo n8n
            [ -x /opt/homebrew/bin/node ] || brew install node@24;

            # Instalar Corepack (ignore erros)
            [ -x "/opt/homebrew/bin/corepack" ] || {
                _echo_task "Atualizando corepack...";
                brew install corepack;
                brew unlink corepack;
                brew link --overwrite corepack;
            };

    else

        # nao-mac
        _echo_task " Pulando brew (nao estamos no Mac)";

    fi;

    echo;

exit 0;

