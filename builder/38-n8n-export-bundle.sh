#!/bin/bash

# Empacotar pasta dos fontes com as dependencias resolvidas
    # Incluir funcoes e variaveis
    . $(dirname $(readlink -f "$0"))/00-lib.sh;

    _echo_title "Empacotando N8N (fontes e dependencias)";

    # Entrar no diretorio dos fontes:
    _cdfolder /opt/homebrew/n8n-current;

    # Diretorio da versao atual
    _echo_task "Limpando diretorio de bundle: /opt/homebrew/n8n-${N8N_VERSION}-$RELEASE-bundle"
    rm -rf  /opt/homebrew/n8n-${N8N_VERSION}-$RELEASE-bundle 2>/dev/null;
    mkdir -p /opt/homebrew/n8n-${N8N_VERSION}-$RELEASE-bundle;

    # Copiando fontes
    _echo_task "Copiando fontes";
    _echo_task "  Origem.: /opt/homebrew/n8n-current";
    _echo_task "  Destino: /opt/homebrew/n8n-${N8N_VERSION}-$RELEASE-bundle";
    _echo_gray "  rsync -razp '/opt/homebrew/n8n-current/' '/opt/homebrew/n8n-${N8N_VERSION}-$RELEASE-bundle/'";
    CMD="rsync -razp /opt/homebrew/n8n-current/ /opt/homebrew/n8n-${N8N_VERSION}-$RELEASE-bundle/";
    _eval "$CMD";

    _echo_task "Sincronizando disco...";
    _eval "sync";
    _eval "sleep 0.5";

    # Nao incluir compiled, caso presente
    [ -d "/opt/homebrew/n8n-${N8N_VERSION}-$RELEASE-bundle/compiled" ] && {
    	_echo_gray "Apagando: /opt/homebrew/n8n-${N8N_VERSION}-$RELEASE-bundle/compiled";
    	rm -rf "/opt/homebrew/n8n-${N8N_VERSION}-$RELEASE-bundle/compiled";
    };

    # Gerar pacote da pasta bundle
    BUNDLE_PKG="/root/n8n-${N8N_VERSION}-$RELEASE-bundle.tgz";
    rm -f "$BUNDLE_PKG" 2>/dev/null;
    _cdfolder /opt/homebrew;
    CMD="tar -cpzf $BUNDLE_PKG n8n-${N8N_VERSION}-$RELEASE-bundle";
    _echo_task "Empacotando pacote de fontes (pasta n8n-${N8N_VERSION}-$RELEASE-bundle, pwd $PWD) em: $BUNDLE_PKG";
    _eval "$CMD";

    # Limpar pasta copiada
	_echo_gray "Apagando: /opt/homebrew/n8n-${N8N_VERSION}-$RELEASE-bundle";
	rm -rf "/opt/homebrew/n8n-${N8N_VERSION}-$RELEASE-bundle" 2>/dev/null;

    _echo_task "Pacote bundle pronto: $BUNDLE_PKG";
    echo;

exit 0;

