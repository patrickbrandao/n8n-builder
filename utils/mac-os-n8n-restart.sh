#!/bin/bash


    # Criar pasta para community-nodes:
    mkdir -p /opt/homebrew/n8n-nodes;

    # Criar pasta de arquivos do processo:
    mkdir -p /opt/homebrew/n8n-data;


    #------------------------------------------- Parar
    # Parar os serviços
    launchctl  stop  com.n8n-editor;
    launchctl  stop  com.n8n-webhook;
    launchctl  stop  com.n8n-worker;

    # Desregistrar (para atualizar)
    launchctl  unload  ~/Library/LaunchAgents/com.n8n-editor.plist  2>/dev/null;
    launchctl  unload  ~/Library/LaunchAgents/com.n8n-webhook.plist 2>/dev/null;
    launchctl  unload  ~/Library/LaunchAgents/com.n8n-worker.plist  2>/dev/null;

    # Limpar logs
    echo -n > /tmp/n8n-editor-error.log;
    echo -n > /tmp/n8n-editor-stdout.log;
    echo -n > /tmp/n8n-webhook-error.log;
    echo -n > /tmp/n8n-webhook-stdout.log;
    echo -n > /tmp/n8n-worker-error.log;
    echo -n > /tmp/n8n-worker-stdout.log;


    #------------------------------------------- Iniciar
    # Carregar no cadastro de serviços:
    launchctl  load  ~/Library/LaunchAgents/com.n8n-editor.plist;
    launchctl  load  ~/Library/LaunchAgents/com.n8n-webhook.plist;
    launchctl  load  ~/Library/LaunchAgents/com.n8n-worker.plist;

    # Iniciar os serviços
    # launchctl  start  com.n8n-editor;
    # launchctl  start  com.n8n-webhook;
    # launchctl  start  com.n8n-worker;


    # Verificar status
    launchctl list | grep n8n;
        # 26377   0       com.n8n-webhook
        # 26080   0       com.n8n-editor
        # 26077   1       com.n8n-worker



    # Ver logs
    tail -n 20 /tmp/n8n*;

    # Acompanhar logs
    tail -f /tmp/n8n*;



exit 0;
