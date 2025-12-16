#!/bin/bash

# Rodar padrao N8N+PG sem Worker, base em Postgres

	# Imagem do N8N
	export N8N_IMAGE="n8n-private:2.1.0";

	# Diretorio de volumes
	export RUN_DIR=/storage/benchmark-sqlite;
	mkdir -p $RUN_DIR;
	mkdir -p $RUN_DIR/n8n;

	# Subir stack
	docker compose -p benchmark-n8n-sqlite down;
	docker compose -p benchmark-n8n-sqlite up -d;

	# Acesso: http://172.31.100.101:5678/

exit 0;

