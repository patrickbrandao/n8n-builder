#!/bin/bash

# Resetar usuario do N8N

    # Funcoes
    _abort(){ echo; echo "Erro fatal $1"; echo; exit $2; };
    _echo_lighcyan(){ /bin/echo -e "\x1B[96m$@\033[0m"; }
    _echo_lighyellow(){ /bin/echo -e "\x1B[93m$@\033[0m"; }
    _echo_title(){ echo; printf "\033[33;7m > \033[0m\033[32;7m $1 \033[0m\n"; };


    _echo_title "# N8N SQLITE3 - Resetar usuario administrador";

    # Argumento 1 - caminho para o banco de dados
    SQDB="$1";
    [ "x$SQDB" = "x" ] && _abort "Arquivo SQLITE nao informado" 11;
    [ -f "$SQDB" ] || _abort "Arquivo SQLITE nao encontrado ($SQDB)" 12;
    DIRNAME=$(dirname "$SQDB");

    _echo_lighcyan "# Diretorio......: $DIRNAME";
    _echo_lighcyan "# Arquivo........: $SQDB";

    # Fazer backup por seguranca
    NOWDT=$(date '+%Y-%m-%d-%H%M');
    SQDUMP="$DIRNAME/dump-$NOWDT.sql";
    _echo_lighcyan "# Fazendo backup.: $SQDUMP";
    sqlite3 $SQDB .dump > $SQDUMP;


    # Dados do usuario
    FIRST_NAME="Acme";
    LAST_NAME="Jobs";
    USER_EMAIL="admin@acme.com";
    USER_PASSWD="Acme@123";

    # Senha: Acme@123
    # n8n usa padrao bcrypt descontinuado
    USER_BCRYPT_PASSWD='$2a$10$mBk9VYko1q0GYf4/D0vh3O08torSyfcH48znhwe4Z3pUl2h9Aewi.'; 

    _echo_lighcyan "# Administrador..: $FIRST_NAME $LAST_NAME";
    _echo_lighcyan "# Email (login)..: $USER_EMAIL";
    _echo_lighcyan "# Senha..........: $USER_PASSWD";

    # Executando alteracoes

    # 1 - Preencher dados no projeto
    PROJECT_ID=$(sqlite3 "$SQDB" "SELECT id FROM project LIMIT 1;");
    sqlite3 "$SQDB" "UPDATE project SET name = '$FIRST_NAME $LAST_NAME <$USER_EMAIL>', updatedAt = createdAt WHERE id = '$PROJECT_ID';"

    # 2 - Marcar instancia como inicializada
    sqlite3 "$SQDB" "UPDATE settings SET value = 'true' WHERE key = 'userManagement.isInstanceOwnerSetUp';"

    # 3 - Definir login
    # Obter id do usuario padrao
    USER_UUID=$(sqlite3 "$SQDB" "SELECT id FROM user LIMIT 1;");
    # Remover UUID de usuario indefinido

    # Definir dados pessoais
    sqlite3 "$SQDB" "UPDATE user SET email = '$USER_EMAIL', firstName = '$FIRST_NAME', lastName = '$LAST_NAME' WHERE id = '$USER_UUID';"

    # Definir senha
    sqlite3 "$SQDB" "UPDATE user SET password = '$USER_BCRYPT_PASSWD' WHERE id = '$USER_UUID';"

    # Definir data de ativacao
    TODAY=$(date '+%Y-%m-%d');
    NOWDT=$(date '+%Y-%m-%d-%H%M');
    sqlite3 "$SQDB" "UPDATE user SET lastActiveAt = '$TODAY', updatedAt = $NOWDT WHERE id = '$USER_UUID';"


    _echo_lighcyan "# Concluido.";
    echo;


exit 0;

