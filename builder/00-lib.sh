#!/bin/bash

# Biblioteca de funcoes e variaveis de ambiente

    # Detectar ambiente
    UNAMEO=$(uname -o);

    IS_LINUX=no; [ "$UNAMEO" = "GNU/Linux" ] && IS_LINUX=yes;
    IS_MACOS=no; [ "$UNAMEO" = "Darwin"    ] && IS_MACOS=yes;

    # Argumentos do comando sed de acordo com plataforma
    SEDARG="";
    [ "$IS_MACOS" = "yes" ] && SEDARG=".bck1";

    # Extensao de arquivo de backup
    BCKEXT="orig";

    # Ultimo arquivo alterado com o sed
    SEDFILE="";

    # Versao do N8N
    [ "x$N8N_VERSION" = "x" ] && N8N_VERSION=$(head -1 "/tmp/.n8n-version" 2>/dev/null);
    [ "x$N8N_VERSION" = "x" ] && {
        N8N_VERSION="1.121.3";
        echo "$N8N_VERSION" > /tmp/.n8n-version;
    };
    export N8N_VERSION="$N8N_VERSION";

    # Release de compilacao
    [ "x$RELEASE" = "x" ] && RELEASE=$(head -1 /tmp/.release 2>/dev/null);
    [ "x$RELEASE" = "x" ] && {
        RELEASE="private";
        echo "$RELEASE" > /tmp/.release;
    };
    export RELEASE="$RELEASE";

    # Nome da imagem do n8n
    export N8N_IMAGE="n8n-$RELEASE";
    export N8N_TAG1="n8n-$RELEASE:$N8N_VERSION";
    export N8N_TAG2="n8n-$RELEASE:latest";


    # Detectar versao do executores envolvidos

    # Versoes do nodejs usados na base
    bnv="22.21.0";
    tmp_base_df="/opt/homebrew/n8n-current/docker/images/n8n-base/Dockerfile";
    if [ -d /opt/homebrew/n8n-current -a -f "$tmp_base_df" ]; then
        # Versao do NodeJS
        bnv=$(egrep 'ARG.NODE_VERSION' $tmp_base_df | cut -f2 -d=);
        [ "x$bnv" = "x" ] && _abort "BASE: Incapaz de determinar versao do NodeJS" 22;
        # Gravar
        echo "$bnv" > /tmp/.base-node-version;
    fi;
    export BASE_NODE_VERSION="$bnv"


    # Versoes do python e nodejs usados no runner
    RUNNERS_PYTHON_VERSION="3.13";
    RUNNERS_NODE_VERSION="22.21.0";
    tmp_runner_df="/opt/homebrew/n8n-current/docker/images/runners/Dockerfile";
    if [ -d /opt/homebrew/n8n-current -a -f "$tmp_runner_df" ]; then
        # Detectar versao do Python
        RUNNERS_PYTHON_VERSION=$(egrep 'ARG.PYTHON_VERSION' "$tmp_runner_df" | cut -f2 -d=);
        [ "x$RUNNERS_PYTHON_VERSION" = "x" ] && _abort "RUNNER: Incapaz de determinar versao do Python" 22;

        # Versao do NodeJS
        RUNNERS_NODE_VERSION=$(egrep 'ARG.NODE_VERSION' $tmp_runner_df | cut -f2 -d=);
        [ "x$RUNNERS_NODE_VERSION" = "x" ] && _abort "RUNNER: Incapaz de determinar versao do NodeJS" 22;

        # Gravar
        echo "$RUNNERS_PYTHON_VERSION" > /tmp/.runner-python-version;
        echo "$RUNNERS_NODE_VERSION" > /tmp/.runner-node-version;
    fi;


    # Imagem publica dos runners (baseado na versao do nodejs)
    export RUNNERS_PUBLIC_IMAGE="ghcr.io/n8n-io/runners:${BASE_NODE_VERSION}";

    # Imagem publica da base
    export BASE_PUBLIC_IMAGE="n8nio/base:${BASE_NODE_VERSION}";


    # Imagem de base
    export BASE_IMAGE="n8n-base-$RELEASE";
    export BASE_TAG1="$BASE_IMAGE:latest";
    export BASE_TAG2="$BASE_IMAGE:$BASE_NODE_VERSION";

    # Nome do container para rodar a compilaca
    export CONTAINER_BASE_NAME="n8nio-base-$RELEASE";


# Biblioteca de funcoes shell script
	_echo_lighcyan(){ /bin/echo -e "\x1B[96m$@\033[0m"; }
    _echo_gray(){ printf "   \033[37;2m$1\033[0m\n"; };
    _echo_fatal(){ printf "   \033[31;7m $1 \033[0m\n"; };
    _echo_task(){ printf "   \033[37;7m > \033[0m\033[36;7m $1 \033[0m\n"; };
    _echo_warn(){ echo; printf "\033[31;7m x \033[33;7m $1 \033[0m\n"; echo; };
    _echo_title(){ echo; printf "\033[39;7m ~ \033[0m\033[32;7m $1 \033[0m\n"; };
    _echo_exec(){ echo; printf "\033[34;7m > \033[33;6m $1 \033[0m\n"; };
    _echo_replace(){
        printf "\033[37;7m > \033[0m\033[36;7m $1 \033[0m\n";
        printf "  \033[36;4m$2\033[0m\n"
        printf "  \033[31;1m$3\033[0m\n";
        printf "  \033[32;1m$4\033[0m\n";
    };
    _echo_diff(){
        #printf "\033[37;7m > \033[0m\033[36;7m $1 \033[0m\n";
        printf "  \033[34;7m > \033[33;6m $1 \033[0m\n";
        printf "  -> \033[33;4m$2\033[0m\n"
        printf "  +> \033[36;4m$3\033[0m\n"
    };
    _abort(){ echo; _echo_fatal "Erro fatal $1"; echo; exit $2; };
    _cdfolder(){ echo "Acessando diretorio $1"; cd $1 || _abort "Erro ao acessar diretorio $1"; }

    # Arquivo para patch
    _backup(){
        F="$1";
        [ -f "$F.$BCKEXT" ] || { _echo_gray "BACKUP: $F -> $F.$BCKEXT"; cp $F $F.$BCKEXT; };
        [ -f "$F.$BCKEXT" ] && { _echo_gray "RESET.: $F.$BCKEXT -> $F"; cp $F.$BCKEXT $F; };
        SEDFILE="$F";
    };

    #printf "\033[37;2mHello World! faint\033[0m\n"

    # Comparar diferencas entre arquivo origianl (.$BCKEXT)
    # e sua nova versao alterada pelo sed
    _sed_diff(){
        echo;
        CMD="diff --color=always -Naur $SEDFILE.$BCKEXT $SEDFILE";
        _echo_diff "SED DIFF" "$SEDFILE.$BCKEXT" "$SEDFILE";
        #_echo_exec "$CMD";
        $CMD 2>/dev/null;
        echo;
    };

    # Ultimo arquivo alterado
    LASTFILE="";
    _fast_replace(){
        fle="$1";  # arquivo
        fstr="$2"; # procurar
        frep="$3"; # substituir
        _echo_replace "Fast replace" "$fle" "$fstr" "$frep";
        # backup inicial
        [ -f "$fle.old" ] || cp "$fle" "$fle.old";
        sed -i $SEDARG "s#$fstr#$frep#g" "$fle";
        LASTFILE="$fle";
    };
    _fast_diff(){
        echo;
        CMD="diff --color=always -Naur $LASTFILE.old $LASTFILE";
        #_echo_diff "DIFF" "$LASTFILE.old" "$LASTFILE";
        $CMD 2>/dev/null;
        echo;
    };

    # Comparar diferencas entre arquivo original e arquivo com extencao .old
    _old_diff(){
        echo;
        #_echo_diff "DIFF" "$1.old" "$1";
        diff --color=always -Naur $1.old $1 2>/dev/null;
        echo;
    };

    # Funcao para exportar imagem
    _oci_export(){
        image="$1"; tmptar="$2"; outtgz="$3";

        # nao repetir compressao
        if [ -f "$outtgz" ]; then
            _echo_task "oci_export - Ignorando, arquivo ja existe: $outtgz";
            return 1;
        fi;

        _echo_task "oci_export - Exportando imagem [$image] para [$tmptar]";

        # exportar do docker para arquivo tar
        docker save $image > $tmptar 2>/dev/null; stdno="$?";
        [ "$stdno" = "0" ] || _abort "Erro $stdno ao exportar imagem [$image]";

        # comprimir (tar+gz max)
        _echo_task "oci_export - Comprimindo para $outtgz";
        (cd /opt/homebrew; pv $tmptar | pigz -9 -p 64 > $outtgz; );

        # limpar tar
        rm -f "$tmptar" 2>/dev/null;

        _echo_task "oci_export -> Imagem salva: $outtgz";
        return 0;
    };

    # Baixar arquivos
    _wget(){
        WURL="$1";
        WDST="$2";
        [ -f "$WDST" ] && return 0;
        _echo_exec "wget -O $WDST $WURL";
        wget -O "$WDST" "$WURL" 2>/dev/null 1>/dev/null && return 0;
        rm -f "$WDST" 2>/dev/null; return 1;
    };

    # copiar icone para destino desejado
    ICONS_DIR="/tmp/icons";
    _copy_list(){
        [ -d "$ICONS_DIR" ] || mkdir -p "$ICONS_DIR";
        CLSRC="$ICONS_DIR/$1";
        CLDST="$2";
        for dst in $CLDST; do
            _echo_task "Copiando $CLSRC para $dst";
            cp "$CLSRC" "$dst";
        done;
    };


