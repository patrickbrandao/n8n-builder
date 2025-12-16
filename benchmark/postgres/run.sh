#!/bin/bash

# Rodar padrao N8N+PG sem Worker, base em Postgres

	# Imagem do N8N
	export N8N_IMAGE="n8n-private:2.1.0";

	# Diretorio de volumes
	export RUN_DIR=/storage/benchmark-postgres;
	mkdir -p $RUN_DIR;
	mkdir -p $RUN_DIR/n8n;
	mkdir -p $RUN_DIR/postgres;

	# Subir stack
	docker compose -p benchmark-n8n-pg down;
	docker compose -p benchmark-n8n-pg up -d;

	# Acesso: http://172.31.101.102:5678/

exit 0;

