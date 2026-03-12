# Exportar projeto em markdown
(
    echo '# N8N v2 Deploy';
    echo;
    echo '## Arquivos ENV';
    for envfile in /root/n8n-deploy/.env*; do
        echo "### $envfile";
        echo;
        echo '```env'; cat $envfile; echo '```';
        echo;
    done;
    echo;
    echo '## Scripts';
    for script in /root/n8n-deploy/run*; do
        echo "### $script";
        echo;
        echo '```bash'; cat $script; echo '```';
        echo;
    done;
    echo;
) > /root/n8n-deploy/README.md;
