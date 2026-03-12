# Pasta para volume dos containers
    mkdir -p /storage/n8n-app;
    mkdir -p /storage/n8n-app/editor;
    mkdir -p /storage/n8n-app/worker;
    mkdir -p /storage/n8n-app/webhook;
    mkdir -p /storage/n8n-app/runner;

# Corrigir permissoes:
    chown -R 1000:1000 /storage/n8n-app;

