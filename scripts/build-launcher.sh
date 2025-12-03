#!/bin/sh


# Script para compilar task-runner launcher

    LAUNCHER_VERSION=1.4.1

    # Plataforma
    MODE="normal";
    TARGETPLATFORM="linux/amd64";
    ARCH_NAME="amd64";
    UNAMEO=$(uname -o);
    [ "$UNAMEO" = "Darwin" ] && {
        MODE="macos";
        TARGETPLATFORM="arm64";
        ARCH_NAME="arm64";
    };


    # Criar uid 1000 (node)
    addgroup -g 1000 node || exit 11;
    adduser -G node -u 1000 node -s /bin/sh -h /home/node -D || exit 12;

    # atualizar
    apk update || exit 21;
    apk upgrade || exit 22;

    # instalar ferramentas
    apk add bash curl wget git git || exit 23;

    # preparar diretorio de compilacao
    rm -rf /runners 2>/dev/null;
    mkdir -p /runners || exit 31;
    chown -R node:node /runners || exit 32;

    # obter fontes
	cd /runners/;
	git clone https://github.com/n8n-io/task-runner-launcher.git;

	# entrar nos fontes baixados
	cd /runners/task-runner-launcher || exit 41;


    # Compilar launcher
    if [ "$MODE" = "macos" ]; then
        # Compilar com otimizações
         GOOS=darwin GOARCH=arm64 go build -ldflags='-s -w' -o task-runner-launcher ./cmd/launcher || exit 51;
    else
        # Compilar (modo simples)
        go build -o task-runner-launcher ./cmd/launcher || exit 52;
    fi;


    # Copiar para compiled, /app/compiled/
    mkdir -p /app/runners/;
    cp /runners/task-runner-launcher/task-runner-launcher /app/runners/ || exit 61;

    # Ajustar permissoes
    chown -R node:node /app/runners;

exit 0;

