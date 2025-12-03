#!/bin/bash

# Upar imagens para storage
    # Incluir funcoes e variaveis
    . $(dirname $(readlink -f "$0"))/00-lib.sh;

    # Funcao de upload
    SERVER_ADDR="seu-servidor.dominio.com.br";
    SERVER_URI="root@$SERVER_ADDR:/storage/images/";
    SERVER_PORT="1822";
    _upload(){
        local_file="$1";
        [ -f "$local_file" ] || {
            _echo_warn "Erro, arquivo ausente: $local_file";
            return 0;
        };
        _echo_task "Enviando arquivo $local_file para $SERVER_URI";
        _echo_exec "rsync -ravzp -e 'ssh -p$SERVER_PORT' $local_file $SERVER_URI";
        rsync -ravzp -e "ssh -p$SERVER_PORT" $local_file $SERVER_URI;
    };


    # Iniciando
    _echo_title "Fazendo upload dos arquivos OCI, n8n $N8N_VERSION, release $RELEASE";


    # Gerar nome de arquivos
    N8N_TGZ_PACKAGE="/root/n8n-${RELEASE}-$N8N_VERSION-oci.tgz";
    BASE_TGZ_PACKAGE="/root/n8n-base-${RELEASE}-$BASE_NODE_VERSION-oci.tgz";
    RUNDEF_TGZ_PACKAGE="/root/n8n-runners-${RELEASE}-default-$N8N_VERSION-oci.tgz";
    RUNDLS_TGZ_PACKAGE="/root/n8n-runners-${RELEASE}-distroless-$N8N_VERSION-oci.tgz";


    # Caminho do storage
    # Upar
    _upload  "$N8N_TGZ_PACKAGE";
    _upload  "$BASE_TGZ_PACKAGE";
    _upload  "$RUNDEF_TGZ_PACKAGE";
    _upload  "$RUNDLS_TGZ_PACKAGE";

    _echo_task "Upload concluido.";
    echo;


exit 0;

