#!/bin/bash

# Definir login e senha no primeiro acesso

    # Funcoes
    _abort(){ echo; echo "Erro fatal $1"; echo; exit $2; };
    _echo_lighcyan(){ /bin/echo -e "\x1B[96m$@\033[0m"; }
    _echo_lighyellow(){ /bin/echo -e "\x1B[93m$@\033[0m"; }
    _echo_title(){ echo; printf "\033[33;7m > \033[0m\033[32;7m $1 \033[0m\n"; };


    _echo_title "# N8N SETUP - Configurar usuario administrador no primeiro acesso";

    # Argumento 1 - URL base de acesso: https://n8n:1234
    BASE_URL="$1";
    [ "x$BASE_URL" = "x" ] && _abort "Informe o endereco HTTP do N8N" 11;

    _echo_lighcyan "# Acesso HTTP....: $BASE_URL";

    # Dados do usuario
    FIRST_NAME="${2:-Acme}";
    LAST_NAME="${3:-Jobs}";
    USER_EMAIL="${4:-admin@acme.com}";
    USER_PASSWD="${5:-Acme@123}";

    _echo_lighcyan "# Administrador..: $FIRST_NAME $LAST_NAME";
    _echo_lighcyan "# Email (login)..: $USER_EMAIL";
    _echo_lighcyan "# Senha..........: $USER_PASSWD";

    # Json de definicao de login
    JSON="{ \"email\": \"$USER_EMAIL\", \"firstName\": \"$FIRST_NAME\", \"lastName\": \"$LAST_NAME\", \"password\": \"$USER_PASSWD\" }";

    _echo_title "Enviando $JSON para $BASE_URL/rest/owner/setup";
    curl -v \
        -X POST \
        -H 'Accept: application/json, text/plain, */*' \
        -H 'Content-Type: application/json' \
        -d "$JSON" \
        "$BASE_URL/rest/owner/setup";


exit 0;

 
