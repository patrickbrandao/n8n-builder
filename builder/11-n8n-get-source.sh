#!/bin/bash

# Obter codigo fonte e colocar na pasta de trabalho

    # Incluir funcoes e variaveis
    . $(dirname $(readlink -f "$0"))/00-lib.sh;

    _echo_title "Preparar fontes do N8N";
    mkdir -p /opt/homebrew;

    # Versoes:
    # - v2-dev
    # - 1.121.3

    # Pasta para salvar downloads
    FILEDIR="/root";
    [ "$IS_MACOS" = "yes" ] &&  FILEDIR="$HOME/Downloads";
    mkdir -p "$FILEDIR";


    # Pacote pronto local
    N8N_PACKAGE="$FILEDIR/n8n-$N8N_VERSION-git.tgz"


    # Diretorio com fonte
    N8N_BASEDIR="/opt/homebrew";
    N8N_DIRNAME="n8n-$N8N_VERSION";
    N8N_DIRECTORY="/opt/homebrew/n8n-$N8N_VERSION";


    # Diretorio final
    N8N_SOURCEDIR="/opt/homebrew/n8n-current";


    _echo_task "Versao.: $N8N_VERSION";
    _echo_task "Pacote.: $N8N_PACKAGE";
    _echo_task "Pasta..: $N8N_DIRECTORY";
    _echo_task "SrcDir.: $N8N_SOURCEDIR";

    # Conferir se ja existe
    if [ -f /opt/homebrew/n8n-current/package.json ]; then
        _echo_task "Fontes presentes (/opt/homebrew/n8n-current/package.json)";
        echo;
        exit 0;
    fi

    # Pacote presente encontrado
    if [ -f "$N8N_PACKAGE" ]; then
        _echo_task "! Fontes locais encontrados em: $N8N_PACKAGE";

        # Usar pacote presente
        _echo_task "Usando pacote local: $N8N_PACKAGE";
        mkdir -p /opt/homebrew/tmp/;
        cd /opt/homebrew/tmp || _abort "Erro $? ao acessar diretorio /opt/homebrew/tmp" 10;
        CMD="tar -xf $N8N_PACKAGE -C .";
        _echo_exec "$CMD";
        eval "$CMD" || _abort "Erro $? ao executar: $CMD" 11;

        # Conferir fontes baixados
        if [ -f "$N8N_DIRNAME/package.json" ]; then
            # Ok, funcionou
            rm -rf /opt/homebrew/n8n-current 2>/dev/null;
            _echo_task "Copiando $N8N_DIRNAME/ para /opt/homebrew/n8n-current/";
            mv "$N8N_DIRNAME" "/opt/homebrew/n8n-current" || \
                _abort "Erro $? ao mover [$N8N_DIRNAME] para [/opt/homebrew/n8n-current/]" 12;

        else
            # Problema, pacote invalido
            # - limpar diretorio temporario
            _echo_task "Limpando pasta temporaria (descompressao com problema)";
            rm -rf "/opt/homebrew/tmp" 2>/dev/null;
        fi;

        # Algo deu errado...
        if [ -f /opt/homebrew/n8n-current/package.json ]; then
            _echo_task "Fontes em cache descomprimidos com sucesso (/opt/homebrew/n8n-current/)";
            echo;
            exit 0;
        fi;

        _echo_task "Fontes em cache inuteis, continuando...";
        sleep 1;

    else
        _echo_task "Fontes locais AUSENTES, arquivo nao encontrado: $N8N_PACKAGE";
    fi;



    # Baixar do GitHub
    _echo_task "Requer obtencao de fontes do projeto no Github";

    _echo_task "Baixar no diretorio $N8N_DIRECTORY";
    mkdir -p "$N8N_DIRECTORY";
    cd "$N8N_DIRECTORY" || _abort "Erro $? ao acessar diretorio [$N8N_DIRECTORY]" 13;



    # Conferir se ja esta presente
    if [ -f "$N8N_DIRECTORY/package.json" ]; then
        _echo_task "Fontes locais presentes, pulando git";
    else
        _echo_task "Puxando do github...";

        # conferindo versao
        echo "$N8N_VERSION" | egrep -q '^v2';
        if [ "$?" = "0" ]; then
            # Versao 2 dev/beta
            _echo_task "Puxando branch $N8N_VERSION dev/beta...";
            git clone \
                --branch $N8N_VERSION \
                --single-branch https://github.com/n8n-io/n8n.git . || {
                _abort "Erro $? ao executar git clone (erro $?)" 14;
            };
        else
            # Versao corrente
            _echo_task "Puxando branch release/$N8N_VERSION ...";
            git clone \
                --branch release/$N8N_VERSION \
                --single-branch https://github.com/n8n-io/n8n.git . || {
                _abort "Erro $? ao executar git clone (erro $?)" 14;
            };
        fi;
    fi;



    # Conferir se veio certo
    if [ -f "$N8N_DIRECTORY/package.json" ]; then
        _echo_task "Fontes do git OK";
    else
        _echo_task "Fontes do git com problemas, faltou: [$N8N_DIRECTORY/package.json]";
    echo;
        exit 0;
    fi;


    # Empacotar
    _echo_task "Comprimindo fontes [$N8N_BASEDIR] ($N8N_DIRNAME) para cache local em $N8N_PACKAGE";
    mkdir -p $HOME/Downloads;
    cd $N8N_BASEDIR;
    CMD="tar -cpzvf $N8N_PACKAGE $N8N_DIRNAME";
    _echo_exec "$CMD";
    eval "$CMD" || _abort "Erro $? ao executar: $CMD" 15;


    # Colocar pasta da versao na pasta n8n-current
    _echo_task "Movendo diretorio dos fontes ($N8N_DIRECTORY) para pasta de trabalho /opt/homebrew/n8n-current";
    rm -rf /opt/homebrew/n8n-current 2>/dev/null;
    mv "$N8N_DIRECTORY" "/opt/homebrew/n8n-current";


    # Entrar no diretorio:
    _echo_task "Acessando /opt/homebrew/n8n-current";
    _cdfolder /opt/homebrew/n8n-current;
    echo;



exit 0;

