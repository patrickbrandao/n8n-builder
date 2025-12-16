#!/bin/bash

# Fazer alteracoes nos fontes para trocar valores fixos por valores configuraveis

    # Incluir funcoes e variaveis
    . $(dirname $(readlink -f "$0"))/00-lib.sh;

    _echo_title "Aplicando correcos no N8N (hard-coded)";

    # Entrar no diretorio dos fontes:
    _cdfolder /opt/homebrew/n8n-current;

    # Extensao de backups dos fontes originais
    BCKEXT="hdr";


    # Procurar referencias:
    #     egrep -nre QUEUE_DATABASE_PREFIX .


    # Mudar nome das filas para usar variaveis de ambiente
    # Criar constante com database do Redis
    TARGET="./packages/cli/src/scaling/constants.ts";
    _backup "$TARGET";
    sed -i $SEDARG "/QUEUE_NAME/a export const QUEUE_DATABASE_PREFIX = process.env.QUEUE_BULL_REDIS_DB || '';" $TARGET;
    sed -i $SEDARG '/JOB_TYPE_NAME/a const withPrefix = (channelName: string) => QUEUE_DATABASE_PREFIX ? `${QUEUE_DATABASE_PREFIX}:${channelName}` : channelName;' $TARGET;
    sed -i $SEDARG "s/export.*COMMAND_PUBSUB_CHANNEL.*/export const COMMAND_PUBSUB_CHANNEL = withPrefix( process.env.QUEUE_PUBSUB_CHANNEL?.trim() || 'n8n.commands' );/" $TARGET;
    sed -i $SEDARG "s/export.*WORKER_RESPONSE.*/export const WORKER_RESPONSE_PUBSUB_CHANNEL = withPrefix( process.env.QUEUE_RESPONSE_CHANNEL?.trim() || 'n8n.worker-response' );/" $TARGET;    
    #sed -i $SEDARG "/COMMAND_PUBSUB_CHANNEL/s/COMMAND_PUBSUB_CHANNEL.=./COMMAND_PUBSUB_CHANNEL = process.env.QUEUE_PUBSUB_CHANNEL?.trim() || /" $TARGET;
    #sed -i $SEDARG "/WORKER_RESPONSE_PUBSUB_CHANNEL/s/WORKER_RESPONSE_PUBSUB_CHANNEL.=./WORKER_RESPONSE_PUBSUB_CHANNEL = process.env.QUEUE_RESPONSE_CHANNEL?.trim() || /" $TARGET;
    _sed_diff;


    # Adicionar contantes nos comandos de boot dos servicos
    # - start.ts
    TARGET="./packages/cli/src/commands/start.ts";
    _backup "$TARGET";
    sed -i $SEDARG "/Subscriber.*subscriber.service/a import { COMMAND_PUBSUB_CHANNEL, WORKER_RESPONSE_PUBSUB_CHANNEL } from '@/scaling/constants';" $TARGET;
    sed -i $SEDARG "/subscriber.subscribe.*n8n.commands/s/'n8n.commands'/COMMAND_PUBSUB_CHANNEL/" $TARGET;
    sed -i $SEDARG "/subscriber.subscribe.*n8n.worker-response/s/'n8n.worker-response'/WORKER_RESPONSE_PUBSUB_CHANNEL/" $TARGET;
    _sed_diff;


    # - webhook.ts
    TARGET="./packages/cli/src/commands/webhook.ts";
    _backup "$TARGET";
    sed -i $SEDARG "/Subscriber.*subscriber.service/a import { COMMAND_PUBSUB_CHANNEL } from '@/scaling/constants';" $TARGET;
    sed -i $SEDARG "/Container.get.Subscriber/s/'n8n.commands'/COMMAND_PUBSUB_CHANNEL/" $TARGET;
    _sed_diff;


    # - worker.ts
    TARGET="./packages/cli/src/commands/worker.ts";
    _backup "$TARGET";
    sed -i $SEDARG "/Subscriber.*subscriber.service/a import { COMMAND_PUBSUB_CHANNEL } from '@/scaling/constants';" $TARGET;
    sed -i $SEDARG "/Container.get.Subscriber/s/'n8n.commands'/COMMAND_PUBSUB_CHANNEL/" $TARGET;
    _sed_diff;


    # - publisher.service.ts
    TARGET="./packages/cli/src/scaling/pubsub/publisher.service.ts";
    _backup "$TARGET";
    sed -i $SEDARG "/import.*IMMEDIATE/s/SELF_SEND_COMMANDS/SELF_SEND_COMMANDS, COMMAND_PUBSUB_CHANNEL, WORKER_RESPONSE_PUBSUB_CHANNEL/" $TARGET;
    sed -i $SEDARG "s/.n8n.commands./COMMAND_PUBSUB_CHANNEL/g" $TARGET;
    sed -i $SEDARG "s/.n8n.worker-response./WORKER_RESPONSE_PUBSUB_CHANNEL/g" $TARGET;
    _sed_diff;


exit 0;


