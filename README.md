
# N8N Builder

Scripts para compilação do N8N.

Criado por **Patrick Brandão**
Email: patrickbrandao@gmail.com
Whatsapp: 31 984052336


## Compilando no Linux

Requer Debian 12 ou 13

Rodar o script run-default-builder.sh para construir no padrao da N8N

Recomendavel subir RamDisk na pasta /opt/homebrew/

Para iniciar, lei o script **run-default-builder.sh**

Execute para começar:
```bash

    export N8N_VERSION="1.122.4"; echo "$N8N_VERSION" > /tmp/.n8n-version;

    # Tipo de compilacao (separa versoes de teste, oficial e personalizadas)
    export RELEASE="private"; echo "$RELEASE" > /tmp/.release;

	sh run-default-builder.sh;

```

## Conferindo imagens criadas

```bash

docker image ls;
docker image ls | grep n8n;
docker image ls | grep runners;

```

