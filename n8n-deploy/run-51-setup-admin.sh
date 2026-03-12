# Nome de DNS para acesso HTTPs
    # - Importar da variavel N8N_HOST no arquivo .env
    . /root/n8n-deploy/.env-n8n-web;

# Dados do formulario
    # Template JSON
    JSON_DATA='{
        "email": "admin@acme.com",
        "firstName": "Acme",
        "lastName": "Jobs",
        "password": "Acme@123"
    }';

    echo "# Definir login administrativo:";
    echo;
    echo "# URL: https://$N8N_HOST/rest/owner/setup";
    echo;
    echo "$JSON_DATA";
    echo;

    curl --insecure \
        -X POST \
        -H 'Accept: application/json, text/plain, */*' \
        -H 'Content-Type: application/json' \
        -d "$JSON_DATA" \
        "https://$N8N_HOST/rest/owner/setup";
