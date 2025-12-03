
# Manual de operacao basica no SQLITE3


## Pre-requisitos do sistema

```bash
    apt -y install sqlite3;
```

## Extrair todos os objetos do banco SQLITE


```bash

    SQDB="/storage/n8n-201-single-sqlite/.n8n/database.sqlite";
    NOWDT=$(date '+%Y-%m-%d-%H%M');
    sqlite3 $SQDB .dump > /tmp/sqdb-dump-$NOWDT.sql;

```

# Extrair apenas schema (sem dados)

```bash

    SQDB="/storage/n8n-201-single-sqlite/.n8n/database.sqlite";
    NOWDT=$(date '+%Y-%m-%d-%H%M');
    sqlite3 $SQDB .schema > /tmp/sqdb-schema-$NOWDT.sql;

```

# Extrair apenas uma tabela específica

```bash

    SQDB="/storage/n8n-201-single-sqlite/.n8n/database.sqlite";
    TABLE="nome_tabela";
    NOWDT=$(date '+%Y-%m-%d-%H%M');
    sqlite3 $SQDB ".dump $TABLE" > /tmp/sqdb-table-$TABLE-$NOWDT.sql;

```


## Acessar arquivo SQLITE do N8N

```bash

    SQDB="/storage/n8n-201-single-sqlite/.n8n/database.sqlite";
    sqlite3 $SQDB;

```

## Principais comandos

```sql

-- Listar todas as tabelas
.tables

-- Ver schema/estrutura de uma tabela específica
.schema nome_tabela

-- Ver todas as tabelas com seus schemas
.schema

-- Ver informações de uma tabela, colunas, tipos, etc
.info nome_tabela

-- Listar índices
.indices

-- Contar registros em uma tabela
SELECT COUNT(*) FROM nome_tabela;

-- Ver primeiras 10 linhas de uma tabela
SELECT * FROM nome_tabela LIMIT 10;

-- Extrair todos os dados
.dump

-- Sair
.quit

```


## Acessar arquivo SQLITE do N8N

```bash

    SQDB="/storage/n8n-201-single-sqlite/.n8n/database.sqlite";
    sqlite3 $SQDB;

```


```sql

-- Ver todas as tabelas
.tables

-- Ver a estrutura completa
.schema

-- Exemplo: se vir uma tabela chamada "workflow", explore-a:
.schema workflow

-- Ver quantos registros tem
SELECT COUNT(*) FROM workflow;

-- Ver os primeiros registros
SELECT * FROM workflow LIMIT 5;

-- Ver só algumas colunas
SELECT id, name, createdAt FROM workflow LIMIT 10;

-- Sair
.exit

```



```bash

SQDB="/storage/n8n-201-single-sqlite/.n8n/database.sqlite";

sqlite3 "$SQDB" ".tables";

sqlite3 "$SQDB" << EOF
.width 20 10
SELECT name as 'Tabela', COUNT(*) as 'Registros' 
FROM sqlite_master 
WHERE type='table' 
GROUP BY name;
EOF

# Exportar como CSV
sqlite3 $SQDB << EOF
.mode csv
.output dados.csv
SELECT * FROM nome_tabela;
.output stdout
EOF

# Exportar como JSON (SQLite 3.38+)
sqlite3 $SQDB ".mode json" ".output dados.json" "SELECT * FROM nome_tabela;"

sqlite3 $SQDB ".schema workflow"


```


```bash

SQDB="/storage/n8n-201-single-sqlite/.n8n/database.sqlite";

# -INSERT INTO project VALUES('JtcaC5b6wLdykXx1','Unnamed Project','personal','2025-11-29 18:16:32.302','2025-11-29 18:16:32.302',NULL,NULL);
# +INSERT INTO project VALUES('JtcaC5b6wLdykXx1','Acme Jobs <admin@acme.com>','personal','2025-11-29 18:16:32.302','2025-11-29 

( echo ".mode csv"; echo "SELECT * FROM project;"  ) | sqlite3 "$SQDB";

sqlite3 "$SQDB" "UPDATE project SET ";


```


## Tabelas do n8n

annotation_tag_entity       oauth_authorization_codes 
auth_identity               oauth_clients
auth_provider_sync_history  oauth_refresh_tokens      
chat_hub_agents             oauth_user_consents       
chat_hub_messages           processed_data
chat_hub_sessions           project
credentials_entity          project_relation
data_table                  role
data_table_column           role_scope
event_destinations          scope
execution_annotation_tags   settings
execution_annotations       shared_credentials
execution_data              shared_workflow
execution_entity            tag_entity
execution_metadata          test_case_execution
folder                      test_run
folder_tag                  user
insights_by_period          user_api_keys
insights_metadata           variables
insights_raw                webhook_entity
installed_nodes             workflow_dependency
installed_packages          workflow_entity
invalid_auth_token          workflow_history
migrations                  workflow_statistics
oauth_access_tokens         workflows_tags


## Fazer dump tabela por tabela

```bash

SQDB="/storage/n8n-201-single-sqlite/.n8n/database.sqlite";

# Listar tabelas
TABLES=$(sqlite3 "$SQDB" ".tables");
TABLES=$(echo $TABLES);

NOWDT=$(date '+%Y-%m-%d-%H%M');
DUMPDIR=/tmp/sqdb-$NOWDT;
mkdir -p $DUMPDIR;

# Extrair tabelas em arquivos separados
for table in $TABLES; do
    # extrair schema
    sqlite3 "$SQDB" ".schema $table" > $DUMPDIR/$table-schema.sql;
    # extrair dados
    sqlite3 "$SQDB" ".dump   $table" > $DUMPDIR/$table-data.sql;
    # extrair dados em CSV
    (
        echo ".mode csv";
        echo ".output $DUMPDIR/$table-data.csv";
        echo "SELECT * FROM $table;";
    ) | sqlite3 "$SQDB" > $DUMPDIR/$table-data.csv;
done;
echo "# Pasta: $DUMPDIR";

# Duas pastas com diferentes dumps para comparacao:
PATH1="/tmp/sqdb-2025-11-29-1722";
PATH2="/tmp/sqdb-2025-11-29-1725";

# Fazer DIFF de esquemas
for table in $TABLES; do
    diff -Naur $PATH1/$table-schema.sql $PATH2/$table-schema.sql;
done;

# Fazer DIFF de dados brutos
for table in $TABLES; do
    diff -Naur $PATH1/$table-data.sql $PATH2/$table-data.sql;
done;

# Fazer DIFF de dados CSV
for table in $TABLES; do
    diff -Naur $PATH1/$table-schema.csv $PATH2/$table-data.csv;
done;

```


## Esquemas mais usados no N8N

```sql

CREATE TABLE IF NOT EXISTS "project" (
    "id"              varchar(36) PRIMARY KEY NOT NULL,
    "name"            varchar(255) NOT NULL,
    "type"            varchar(36) NOT NULL,
    "createdAt"       datetime(3) NOT NULL DEFAULT (STRFTIME('%Y-%m-%d %H:%M:%f', 'NOW')),
    "updatedAt"       datetime(3) NOT NULL DEFAULT (STRFTIME('%Y-%m-%d %H:%M:%f', 'NOW')),
    "icon"            text,
    "description"     VARCHAR(512)
);

CREATE TABLE IF NOT EXISTS "project_relation" (
    "projectId"       varchar(36) NOT NULL,
    "userId"          varchar NOT NULL,
    "role"            varchar NOT NULL,
    "createdAt"       datetime(3) NOT NULL DEFAULT (STRFTIME('%Y-%m-%d %H:%M:%f', 'NOW')),
    "updatedAt"       datetime(3) NOT NULL DEFAULT (STRFTIME('%Y-%m-%d %H:%M:%f', 'NOW'))
);

CREATE TABLE IF NOT EXISTS "settings" (
    "key"             TEXT NOT NULL,
    "value"           TEXT NOT NULL DEFAULT '',
    "loadOnStartup"   boolean NOT NULL default false,PRIMARY KEY("key")
);


CREATE TABLE IF NOT EXISTS "user" (
    "id"                       varchar PRIMARY KEY,
    "email"                    varchar(255),
    "firstName"                varchar(32),
    "lastName"                 varchar(32),
    "password"                 varchar,
    "personalizationAnswers"   text,
    "createdAt"                datetime(3) NOT NULL DEFAULT (STRFTIME('%Y-%m-%d %H:%M:%f', 'NOW')),
    "updatedAt"                datetime(3) NOT NULL DEFAULT (STRFTIME('%Y-%m-%d %H:%M:%f', 'NOW')),
    "settings"                 text,
    "disabled"                 boolean NOT NULL DEFAULT (FALSE),
    "mfaEnabled"               boolean NOT NULL DEFAULT (FALSE),
    "mfaSecret"                text,
    "mfaRecoveryCodes"         text,
    "lastActiveAt"             date,
    "roleSlug"                 varchar(128) NOT NULL DEFAULT ('global:member'),

    CONSTRAINT "UQ_e12875dfb3b1d92d7d7c5377e22" UNIQUE ("email"),
    CONSTRAINT "FK_eaea92ee7bfb9c1b6cd01505d56" FOREIGN KEY ("roleSlug") REFERENCES "role" ("slug")
);
CREATE INDEX "user_role_idx" ON "user" ("roleSlug");

```

## Conferindo dados do login

```bash

echo "# Settings";
sqlite3 "$SQDB" "SELECT key,value FROM settings  WHERE key = 'userManagement.isInstanceOwnerSetUp' LIMIT 1;"; echo;
    # > userManagement.isInstanceOwnerSetUp|false
    # + userManagement.isInstanceOwnerSetUp|true
    # - 

echo "# User";
sqlite3 "$SQDB" "SELECT id,email,firstName,lastName,password FROM user ORDER BY id;"; echo;
    # > 59edc894-6c26-4c2c-a7ca-e54763c52f93||||
    # + 59edc894-6c26-4c2c-a7ca-e54763c52f93|admin@acme.com|Acme|Jobs|$2a$10$mBk9VYko1q0GYf4/D0vh3O08torSyfcH48znhwe4Z3pUl2h9Aewi.
    # - 

echo "# Project";
sqlite3 "$SQDB" "SELECT id,name,type FROM project LIMIT 1;"; echo;
    # > 3QVAS10URgrhBeNt|Unnamed Project|personal
    # + 3QVAS10URgrhBeNt|Acme Jobs <admin@acme.com>|personal
    # - 

echo "# Project Relation";
sqlite3 "$SQDB" "SELECT projectId,userId,role,createdAt,updatedAt FROM project_relation LIMIT 1;"; echo;
    # > 3QVAS10URgrhBeNt|59edc894-6c26-4c2c-a7ca-e54763c52f93|project:personalOwner|2025-11-29 20:22:24.277|2025-11-29 20:22:24.277
    # + 3QVAS10URgrhBeNt|59edc894-6c26-4c2c-a7ca-e54763c52f93|project:personalOwner|2025-11-29 20:22:24.277|2025-11-29 20:22:24.277
    # - 

```



## Setup manual de usuario

### Tabela: project - definir dados do usuario

```bash

# project
# - default
#    "id"              = JtcaC5b6wLdykXx1
#    "name"            = Unnamed Project
#    "type"            = personal
#    "createdAt"       = 2025-11-29 18:16:32.302
#    "updatedAt"       = 2025-11-29 18:16:32.302
#    "icon"            = NULL
#    "description"     = NULL
#
# - pos-config
#    "id"              = JtcaC5b6wLdykXx1
#  * "name"            = admin <admin@acme.com>
#    "type"            = personal
#    "createdAt"       = 2025-11-29 18:16:32.302
#  * "updatedAt"       = 2025-11-29 18:20:55.743
#    "icon"            = NULL
#    "description"     = NULL
#

# Obter id do projeto padrao e alterar usuario
PROJECT_ID=$(sqlite3 "$SQDB" "SELECT id FROM project LIMIT 1;");
sqlite3 "$SQDB" "UPDATE project SET name = 'Acme Jobs <admin@acme.com>', updatedAt = createdAt WHERE id = '$PROJECT_ID';"

# -INSERT INTO project VALUES('yEr9KmcNnWODWnOq','Unnamed Project',           'personal','2025-11-29 20:03:18.840','2025-11-29 20:03:18.840',NULL,NULL);
# +INSERT INTO project VALUES('yEr9KmcNnWODWnOq','Acme Jobs <admin@acme.com>','personal','2025-11-29 20:03:18.840','2025-11-29 20:08:46.949',NULL,NULL);

```

### Tabela: project_relation - Definir relacao com projeto

```bash

# project_relation
# - default
#    "projectId"       = yEr9KmcNnWODWnOq
#    "userId"          = 7acb049a-3b00-4896-b646-b8dcf7aaeb7a
#    "role"            = project:personalOwner
#    "createdAt"       = 2025-11-29 20:03:18.841
#    "updatedAt"       = 2025-11-29 20:03:18.841
#
# - pos-config
#    "projectId"       = yEr9KmcNnWODWnOq
#    "userId"          = 7acb049a-3b00-4896-b646-b8dcf7aaeb7a
#    "role"            = project:personalOwner
#    "createdAt"       = 2025-11-29 20:03:18.841
#    "updatedAt"       = 2025-11-29 20:03:18.841
#

# (sem alteracoes)
# > yEr9KmcNnWODWnOq|7acb049a-3b00-4896-b646-b8dcf7aaeb7a|project:personalOwner|2025-11-29 20:03:18.841|2025-11-29 20:03:18.841
# + yEr9KmcNnWODWnOq|7acb049a-3b00-4896-b646-b8dcf7aaeb7a|project:personalOwner|2025-11-29 20:03:18.841|2025-11-29 20:03:18.841

```

### Tabela: settings - Definir instancia como configurada

```bash

# settings
# - default
#    "key"         = userManagement.isInstanceOwnerSetUp
#    "value"       = false
#
# - pos-config
#    "key"         = userManagement.isInstanceOwnerSetUp
#    "value"       = true
#
# keys:
#    > features.ldap
#    > features.sourceControl
#    > features.sourceControl.sshKeys
#    > ui.banners.dismissed
#    > userManagement.authenticationMethod
#    > userManagement.isInstanceOwnerSetUp
#

# Alterar config como concluida:
sqlite3 "$SQDB" "UPDATE settings SET value = 'true' WHERE key = 'userManagement.isInstanceOwnerSetUp';"

```

### Tabela: user - Definir propriedade do usuario

```bash

# user
# - default
#    "id"                       = cc685c33-cf80-4e20-ab71-d15dea5cf118
#    "email"                    = NULL
#    "firstName"                = NULL
#    "lastName"                 = NULL
#    "password"                 = NULL
#    "personalizationAnswers"   = NULL
#    "createdAt"                = 2025-11-29 18:16:32.035
#    "updatedAt"                = 2025-11-29 18:16:32.035
#    "settings"                 = {"userActivated":false}
#    "disabled"                 = 0
#    "mfaEnabled"               = 0
#    "mfaSecret"                = NULL
#    "mfaRecoveryCodes"         = NULL
#    "lastActiveAt"             = NULL
#    "roleSlug"                 = global:owner
#


# - pos-config
#    "id"                       = cc685c33-cf80-4e20-ab71-d15dea5cf118
#    "email"                    = admin@acme.com
#    "firstName"                = Acme
#    "lastName"                 = Jobs
#    "password"                 = $2a$10$1KlTeOWRYfpv5cd8Fq2ZHeHKdgAwMDMB95Tr2kNfhfcXRbVr99UFe
#    "personalizationAnswers"   = NULL
#    "createdAt"                = 2025-11-29 18:16:32.035
#    "updatedAt"                = 2025-11-29 18:20:55
#    "settings"                 = {"userActivated":false}
#    "disabled"                 = 0
#    "mfaEnabled"               = 0
#    "mfaSecret"                = NULL
#    "mfaRecoveryCodes"         = NULL
#    "lastActiveAt"             = 2025-11-29
#    "roleSlug"                 = global:owner
#

# Obter id do usuario padrao
USER_UUID=$(sqlite3 "$SQDB" "SELECT id FROM user LIMIT 1;");
# Remover UUID de usuario indefinido

# Definir dados pessoais
sqlite3 "$SQDB" "UPDATE user SET email = 'admin@acme.com', firstName = 'Acme', lastName = 'Jobs' WHERE id = '$USER_UUID';"

# Definir senha (Acme@123)
BCRYPTPWD='$2a$10$SeR9pBsKFK7xeupjdFQrL.F2WPJQ3Ba4fXsId6Z4S42rLcjc2fgAa';
BCRYPTPWD='$2a$10$mBk9VYko1q0GYf4/D0vh3O08torSyfcH48znhwe4Z3pUl2h9Aewi.';
sqlite3 "$SQDB" "UPDATE user SET password = '$BCRYPTPWD' WHERE id = '$USER_UUID';"

# Definir data de ativacao
TODAY=$(date '+%Y-%m-%d');
NOWDT=$(date '+%Y-%m-%d-%H%M');
sqlite3 "$SQDB" "UPDATE user SET lastActiveAt = '$TODAY', updatedAt = $NOWDT WHERE id = '$USER_UUID';"

```


