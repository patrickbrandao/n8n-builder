#!/bin/sh

# Script para instalar dependencias
    
    # (rodando como node uid 1000)
    # Compilar n8n - instalar dependencias:
    cd /app || exit 41;

    # Detectar versao do PNPM
    PNPM_VERSION=$(grep packageManager package.json | cut -f4 -d'"' | cut -f2 -d'@');
    [ "x$PNPM_VERSION" = "x" ] && PNPM_VERSION="10.18.3"; #10.22.0

    # Ativar corepack
    corepack prepare pnpm@$PNPM_VERSION --activate || exit 42;

    # Instalar dependencias
    pnpm --loglevel verbose install || exit 43;

exit 0;
