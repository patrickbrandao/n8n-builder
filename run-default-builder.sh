#!/bin/bash

# Compilar N8N para Docker usando padrao N8N
# - Definir versao do N8N  

    # Obter versao atual em https://github.com/n8n-io/n8n/releases
    #export N8N_VERSION="1.122.5"; echo "$N8N_VERSION" > /tmp/.n8n-version;
    #export N8N_VERSION="v2"; echo "$N8N_VERSION" > /tmp/.n8n-version;

    # Tipo de compilacao (separa versoes de teste, oficial e personalizadas)
    #export RELEASE="private"; echo "$RELEASE" > /tmp/.release;
    #export RELEASE="stable";  echo "$RELEASE" > /tmp/.release;
    #export RELEASE="test";    echo "$RELEASE" > /tmp/.release;

    # Versao e release default
    [ -f "/tmp/.n8n-version" ] || {
        export N8N_VERSION="1.122.5";
        echo "$N8N_VERSION" > /tmp/.n8n-version;
        echo "# *** Definindo versao padrao: $N8N_VERSION";
    };
    [ -f "/tmp/.release" ] || {
        export RELEASE="private";
        echo "$RELEASE" > /tmp/.release;
        echo "# *** Definindo release padrao: $RELEASE";
    };
    echo;
    echo "# *** Iniciando com versao $(head -1 /tmp/.n8n-version) e release $(head -1 /tmp/.release)";
    echo;
    sleep 1;

    # Incluir biblioteca de funcoes e variaveis
    echo;
    echo " . Incluindo biblioteca 00-lib.sh";
    echo;
    if [ -f /root/n8n-builder/builder/00-lib.sh ]; then
        source /root/n8n-builder/builder/00-lib.sh;
    else
        echo "FATAL: pasta /root/n8n-builder nao existe.";
        exit 126;
    fi;


# 1 - Rodar preparativos do sistema
    bash /root/n8n-builder/builder/01-prepare-env-debian.sh;
    bash /root/n8n-builder/builder/01-prepare-env-macos.sh;


# 2 - Diretorio de trabalho
    bash /root/n8n-builder/builder/02-mount-workdir.sh;
   

# 3 - Limpar ambiente e apagar compilacao anterior
    bash /root/n8n-builder/builder/04-n8n-clear-workdir.sh;

# 4 - Obter fontes do N8N na pasta do ramdisk
    bash /root/n8n-builder/builder/11-n8n-get-source.sh;

    # Alterar codigo para ajustes
    if [ "$RELEASE" = "private" ]; then
        bash /root/n8n-builder/builder/243n8n-fix-spyware.sh;
        bash /root/n8n-builder/builder/24-n8n-fix-patch.sh;
        bash /root/n8n-builder/builder/25-n8n-fix-env.sh;
        bash /root/n8n-builder/builder/26-n8n-fix-timezone.sh;
    fi;

# 5 - Personalizar estilo
    if [ "$RELEASE" = "private" ]; then
        bash /root/n8n-builder/builder/28-n8n-custom-icons.sh;
        bash /root/n8n-builder/builder/29-n8n-custom-scss.sh;
    fi;

# 6 - Rodar container para compilacao do codigo

    # construir imagem base (ou usar a imagem publica)
    bash /root/n8n-builder/builder/30-n8nbase-oci.sh;

    # rodar container para compilacao
    bash /root/n8n-builder/builder/32-n8nbase-run.sh;
    bash /root/n8n-builder/builder/34-n8nbase-prepare.sh;

    # gerar ./compiled/
    bash /root/n8n-builder/builder/40-n8n-build-compiled.sh;

    # fechar pacote ./compiled/
    bash /root/n8n-builder/builder/52-n8n-pkg-compiled.sh;

    # Alterar codigo para ajustes
    if [ "$RELEASE" = "private" ]; then
        bash /root/n8n-builder/builder/68-n8n-add-syspkg.sh;
    fi;

    # descargar container de compilacao
    bash /root/n8n-builder/builder/78-n8nbase-stop.sh;

    # construir containers do N8N
    # - runners
    #(1)
    bash /root/n8n-builder/builder/84-n8nrunners-oci.sh "default";
    #(2)
    bash /root/n8n-builder/builder/84-n8nrunners-oci.sh "distroless";
    # - n8n
    bash /root/n8n-builder/builder/88-n8n-oci.sh;

    # empacotar imagens OCI
    bash /root/n8n-builder/builder/94-n8n-export-oci.sh;

    # upar para storage proprio
    bash /root/n8n-builder/builder/98-upload-oci.sh;


exit 0;

