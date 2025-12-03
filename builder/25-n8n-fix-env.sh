#!/bin/bash

# Alterar variaveis de ambiente mudando valores padroes

    # Incluir funcoes e variaveis
    . $(dirname $(readlink -f "$0"))/00-lib.sh;

    _echo_title "Alterando variaveis de ambiente padrao do N8N";

    # Entrar no diretorio dos fontes:
    _cdfolder /opt/homebrew/n8n-current;

    # Extensao para salvar arquivos antes da alteracao
    BCKEXT="oenv";

    # - N8N_SECURE_COOKIE, padrao true, alterar para false
    #   para permitir que o n8n abra baseado em qualquer URL
    #   que aponte para ele.
    TARGET="./packages/@n8n/config/src/configs/auth.config.ts";
    _backup "$TARGET";
    sed -i $SEDARG "/N8N_SECURE_COOKIE/{n;s/true/false/;}" "$TARGET";
    _sed_diff;


    # - GENERIC_TIMEZONE, timezone padrao, mudar para Sao_Paulo
    # - N8N_RELEASE_TYPE, mudar de dev para stable
    TARGET="./packages/@n8n/config/src/configs/generic.config.ts";
    _backup "$TARGET";
    sed -i $SEDARG "/N8N_RELEASE_TYPE/{n;s/dev/stable/;}"  "$TARGET";
    _sed_diff;


    # - desativar notificacao de nova versao
    TARGET="./packages/@n8n/config/src/configs/version-notifications.config.ts";
    _backup "$TARGET";
    sed -i $SEDARG '/N8N_VERSION_NOTIFICATIONS_ENABLED/{n;s/true/false/;}'            $TARGET;
    sed -i $SEDARG '/N8N_VERSION_NOTIFICATIONS_WHATS_NEW_ENABLED/{n;s/true/false/;}'  $TARGET;
    _sed_diff;


    # - desativar banner de contratacao de colaboradores
    TARGET="./packages/@n8n/config/src/configs/hiring-banner.config.ts";
    _backup "$TARGET";
    sed -i $SEDARG '/N8N_HIRING_BANNER_ENABLED/{n;s/true/false/;}' $TARGET;
    _sed_diff;


    # desativar botao de github
    TARGET="./packages/frontend/editor-ui/src/app/components/MainHeader/MainHeader.vue";
    _backup "$TARGET";
    sed -i $SEDARG 's/const.githubButtonHidden.*/const githubButtonHidden = true;/' $TARGET;
    _sed_diff;


    # desativar banner dinamico
    TARGET="./packages/@n8n/config/src/configs/dynamic-banners.config.ts";
    _backup "$TARGET";
    sed -i $SEDARG '/N8N_DYNAMIC_BANNERS_ENABLED/{n;s/true/false/;}' $TARGET;
    _sed_diff;


    # permitir javascript irrestrigo
    TARGET="./packages/@n8n/task-runner/src/config/js-runner-config.ts";
    _backup "$TARGET";
    sed -i $SEDARG '/N8N_RUNNERS_INSECURE_MODE/{n;s/false/true/;}' $TARGET;
    _sed_diff;

    # (1)
    # alterar configs padrao do runner, fazer tuning
    TARGET="./packages/@n8n/config/src/configs/runners.config.ts";
    _backup "$TARGET";
    sed -i $SEDARG "/N8N_RUNNERS_AUTH_TOKEN/{n;s/''/'n8n'/;}" $TARGET;
    sed -i $SEDARG "/N8N_RUNNERS_BROKER_LISTEN_ADDRESS/{n;s/127.0.0.1/0.0.0.0/;}" $TARGET;
    sed -i $SEDARG "/N8N_RUNNERS_MAX_CONCURRENCY/{n;s/10/64/;}" $TARGET;
    sed -i $SEDARG "/N8N_RUNNERS_MAX_CONCURRENCY/{n;s/5/64/;}" $TARGET;
    sed -i $SEDARG "/N8N_RUNNERS_TASK_TIMEOUT/{n;s/300/60/;}" $TARGET;
    sed -i $SEDARG '/N8N_RUNNERS_INSECURE_MODE/{n;s/false/true/;}' $TARGET;
    _sed_diff;

    # (2)
    # alterar configs padrao do runner, fazer tuning
    TARGET="./packages/@n8n/task-runner/src/config/base-runner-config.ts";
    _backup "$TARGET";
    sed -i $SEDARG "/N8N_RUNNERS_MAX_CONCURRENCY/{n;s/10/64/;}" $TARGET;
    sed -i $SEDARG "/N8N_RUNNERS_MAX_CONCURRENCY/{n;s/5/64/;}" $TARGET;
    sed -i $SEDARG "/N8N_RUNNERS_TASK_TIMEOUT/{n;s/300/60/;}" $TARGET;
    sed -i $SEDARG '/N8N_RUNNERS_HEALTH_CHECK_SERVER_ENABLED/{n;s/false/true/;}' $TARGET;
    sed -i $SEDARG "/N8N_RUNNERS_HEALTH_CHECK_SERVER_HOST/{n;s/127.0.0.1/0.0.0.0/;}" $TARGET;
    _sed_diff;




    echo;


exit 0

