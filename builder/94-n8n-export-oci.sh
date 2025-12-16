#!/bin/bash

# N8N - Exportar arquivos OCI comprimidos
    # Incluir funcoes e variaveis
    . $(dirname $(readlink -f "$0"))/00-lib.sh;


    # Iniciando
    _echo_title "Exportando imagens OCI para arquivos (versao $N8N_VERSION)";

    # Imagem de base    
    BASE_APP=$(head -1 "/tmp/.n8n-$RELEASE-$N8N_VERSION-image-flag");
    _echo_task "Imagem N8N: $BASE_APP";

    # Imagem de base    
    BASE_IMAGE=$(head -1 "/tmp/.n8n-base-$RELEASE-$BASE_NODE_VERSION-image");
    _echo_task "Imagem base: $BASE_IMAGE";

    # Imagem de runners
    RUNNERS_IMAGE_DEFAULT=$(head -1 "/tmp/.n8n-runners-image-${RELEASE}-default-$N8N_VERSION");
    _echo_task "Imagem runners padrao: $RUNNERS_IMAGE_DEFAULT";

    RUNNERS_IMAGE_DISTROLESS=$(head -1 "/tmp/.n8n-runners-image-${RELEASE}-distroless-$N8N_VERSION");
    _echo_task "Imagem runners distroless: $RUNNERS_IMAGE_DISTROLESS";


    # Gerar nome de arquivos
    # - n8n
    N8N_OCI_PACKAGE="/opt/homebrew/n8n-${RELEASE}-$N8N_VERSION-oci.tar";
    N8N_TGZ_PACKAGE="/root/n8n-${RELEASE}-$N8N_VERSION-oci.tgz";
    # - base
    BASE_OCI_PACKAGE="/opt/homebrew/n8n-base-${RELEASE}-$BASE_NODE_VERSION-oci.tar";
    BASE_TGZ_PACKAGE="/root/n8n-base-${RELEASE}-$BASE_NODE_VERSION-oci.tgz";
    # - runner - default
    RUNDEF_OCI_PACKAGE="/opt/homebrew/n8n-runners-${RELEASE}-default-$N8N_VERSION-oci.tar";
    RUNDEF_TGZ_PACKAGE="/root/n8n-runners-${RELEASE}-default-$N8N_VERSION-oci.tgz";
    # - runner - distroless
    RUNDLS_OCI_PACKAGE="/opt/homebrew/n8n-runners-${RELEASE}-distroless-$N8N_VERSION-oci.tar";
    RUNDLS_TGZ_PACKAGE="/root/n8n-runners-${RELEASE}-distroless-$N8N_VERSION-oci.tgz";


    # - Exportar N8N
    _oci_export "$BASE_APP"    "$N8N_OCI_PACKAGE"   "$N8N_TGZ_PACKAGE"; echo;

    # - Exportar N8N-BASE
    _oci_export "$BASE_IMAGE"  "$BASE_OCI_PACKAGE"  "$BASE_TGZ_PACKAGE"; echo;

    # - Exportar N8N-RUNNERS
    _oci_export "$RUNNERS_IMAGE_DEFAULT"     "$RUNDEF_OCI_PACKAGE"     "$RUNDEF_TGZ_PACKAGE"; echo;
    _oci_export "$RUNNERS_IMAGE_DISTROLESS"  "$RUNDLS_OCI_PACKAGE"  "$RUNDLS_TGZ_PACKAGE"; echo;


    _echo_task "Exportacao concluida";
    echo;


exit 0;


