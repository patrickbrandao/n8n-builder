#!/bin/bash

# Rodar padrao N8N+PG+Redis com Worker e Runners, editor duplo

	# Imagem do N8N
	export N8N_IMAGE="n8n-private:2.1.0";
	export RUNNER_IMAGE="n8n-runners-private-default:2.1.0";

	# Variaveis de ambiente
	export N8N_ENCRYPTION_KEY=n8n;
	export N8N_LICENSE_CERT=acme;
	export N8N_LICENSE_ACTIVATION_KEY="acme-key-5678";
	export N8N_LICENSE_TENANT_ID="1001";

	# Diretorio de volumes
	export RUN_DIR=/storage/benchmark-multi-main;
	mkdir -p $RUN_DIR;
	mkdir -p $RUN_DIR/n8n-worker1;
	mkdir -p $RUN_DIR/n8n-worker2;
	mkdir -p $RUN_DIR/n8n-main1;
	mkdir -p $RUN_DIR/n8n-main2;
	mkdir -p $RUN_DIR/postgres;
	chown 1000:1000 $RUN_DIR -R;

	# Subir stack
	docker compose -p benchmark-n8n-multi-main down;
	docker compose -p benchmark-n8n-multi-main up -d;

	# Acesso ao proxy.....: http://172.31.103.254/
	# Acesso ao editor 1..: http://172.31.103.111:5678/
	# Acesso ao editor 2..: http://172.31.103.112:5678/


exit 0;

      - N8N_MULTI_MAIN_SETUP_ENABLED=true
      - OFFLOAD_MANUAL_EXECUTIONS_TO_WORKERS=true


