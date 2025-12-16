
# N8N Builder

Scripts para compilação do N8N.

Criado por **Patrick Brandão**
Email: patrickbrandao@gmail.com
Whatsapp: 31 984052336


## Compilando no Linux

1. Requer Debian 12 ou 13
2. Baixe esse projeto e coloque-o em /root/n8n-builder/
3. Rodar o script run-default-builder.sh para construir no padrao da N8N
4. Recomendavel subir RamDisk na pasta /opt/homebrew/, precisa ter pelo menos 24G de RAM, rodar o script: utils/install-ramdisk-service.sh
5. Para iniciar, lei o script **run-default-builder.sh**

## Compilando N8N
```bash

    export N8N_VERSION="1.122.4"; echo "$N8N_VERSION" > /tmp/.n8n-version;

    # Tipo de compilacao (separa versoes de teste, oficial e personalizadas)
    export RELEASE="private"; echo "$RELEASE" > /tmp/.release;

	sh /root/n8n-builder/run-default-builder.sh;

```

## Conferindo imagens criadas

```bash

docker image ls;
docker image ls | grep n8n;
docker image ls | grep runners;

```

## Rodando com imagem especifica

```bash

cd /root/n8n-builder/tests;

/root/n8n-builder/tests/setup-211-tapi-workers-internal.sh      n8n-private:1.123.5 n8n-runners-private-default:1.123.5;
/root/n8n-builder/tests/setup-221-tapi-workers-runners.sh       n8n-private:1.123.5 n8n-runners-private-default:1.123.5;
/root/n8n-builder/tests/setup-231-tapi-workers-runners-split.sh n8n-private:1.123.5 n8n-runners-private-default:1.123.5;


/root/n8n-builder/tests/setup-211-tapi-workers-internal.sh      n8n-private:2.0.0 n8n-runners-private-default:2.0.0;
/root/n8n-builder/tests/setup-221-tapi-workers-runners.sh       n8n-private:2.0.0 n8n-runners-private-default:2.0.0;


/root/n8n-builder/tests/setup-231-tapi-workers-runners-split.sh n8n-private:2.0.0 n8n-runners-private-default:2.0.0;
/root/n8n-builder/tests/setup-241-tapi-dual-workers-runners.sh  n8n-private:2.0.0 n8n-runners-private-default:2.0.0;


/root/n8n-builder/tests/setup-211-tapi-workers-internal.sh      n8n-private:2.0.1 n8n-runners-private-default:2.0.1;
/root/n8n-builder/tests/setup-221-tapi-workers-runners.sh       n8n-private:2.0.1 n8n-runners-private-default:2.0.1;


/root/n8n-builder/tests/setup-231-tapi-workers-runners-split.sh n8n-private:2.0.1 n8n-runners-private-default:2.0.1;


/root/n8n-builder/tests/setup-241-tapi-dual-workers-runners.sh  n8n-test:2.0.2      n8n-runners-test-default:2.0.2;
/root/n8n-builder/tests/setup-241-tapi-dual-workers-runners.sh  n8n-private:2.0.2   n8n-runners-private-default:2.0.2;


/root/n8n-builder/tests/setup-251-v2-workers.sh                  n8n-test:2.0.2     n8n-runners-test-default:2.0.2;
/root/n8n-builder/tests/setup-251-v2-workers.sh                  n8n-private:2.0.2  n8n-runners-private-default:2.0.2;

/root/n8n-builder/tests/setup-251-v2-workers.sh                  n8n-test:2.1.0     n8n-runners-test-default:2.1.0;
/root/n8n-builder/tests/setup-251-v2-workers.sh                  n8n-private:2.1.0  n8n-runners-private-default:2.1.0;






```

## Aumentar performance e paralelismo

```

# Palavra chave: CONCURRENCY, concurrency

# Limite de execucoes por runner:
N8N_RUNNERS_MAX_CONCURRENCY default 10

```


