#!/bin/sh

# Script para fazer build/deply do n8n - produz pasta ./compiled/
    
    # (rodando como node uid 1000)
    # Compilar n8n - pacote final
    cd /app || exit 41;

    # Construcao base
    pnpm --loglevel verbose build;

    # Construcao deply
    pnpm --loglevel verbose build:deploy;

exit 0;

