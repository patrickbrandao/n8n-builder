#!/bin/bash

# Rodar padrao N8N+PG+Redis com Worker e Runners, editor unico

	# Imagem do N8N
	export N8N_IMAGE="n8n-private:2.1.0";
	export RUNNER_IMAGE="n8n-runners-private-default:2.1.0";

	# Variaveis de ambiente
	export N8N_ENCRYPTION_KEY=n8n;

	# Diretorio de volumes
	export RUN_DIR=/storage/benchmark-single-main;
	mkdir -p $RUN_DIR;
	mkdir -p $RUN_DIR/n8n-worker1;
	mkdir -p $RUN_DIR/n8n-worker2;
	mkdir -p $RUN_DIR/n8n-main;
	mkdir -p $RUN_DIR/postgres;

	# Subir stack
	docker compose -p benchmark-n8n-single-main down;
	docker compose -p benchmark-n8n-single-main up -d;

	# Acesso: http://172.31.102.107:5678/

exit 0;

