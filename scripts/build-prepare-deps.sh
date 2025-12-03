#!/bin/sh

# Script para preparar ambiente de compilacao
	
	# (rodando como root)

    # Instalar pacotes
    apk update || exit 11;
    apk upgrade || exit 12;
    apk add bash curl wget git strace go git || exit 13;


    # Ajustar permissoes
    cd /app || exit 21;
    chown node:node /app -R || exit 22;
    corepack enable || exit 23;


    # Detectar versao do PNPM
    PNPM_VERSION=$(grep packageManager package.json | cut -f4 -d'"' | cut -f2 -d'@');
    [ "x$PNPM_VERSION" = "x" ] && PNPM_VERSION="10.18.3"; #10.22.0

    # Ativar corepack
    corepack prepare pnpm@$PNPM_VERSION --activate || exit 31;

    # Ajustes finais de permissao
    chown node:node /app -R || exit 32;

    # Ajustes finais de modos de acesso
    chmod -R u+rwX /app || exit 33;


exit 0;
