#!/bin/bash

# Alterar timezone padrao nos fontes

    # Incluir funcoes e variaveis
    . $(dirname $(readlink -f "$0"))/00-lib.sh;

    LOCALTZ="America/Sao_Paulo";
    _echo_title "Alterando timezone padrao para $LOCALTZ";

    # Entrar no diretorio dos fontes:
    _cdfolder /opt/homebrew/n8n-current;

    # Extensao para salvar arquivos antes da alteracao
    BCKEXT="otz";


    # Aplicar alteracoes de timezone
    _fast_replace  "./packages/workflow/src/global-state.ts"                       "America/New_York"  "$LOCALTZ"; _fast_diff;
    _fast_replace  "./packages/@n8n/config/src/configs/generic.config.ts"          "America/New_York"  "$LOCALTZ"; _fast_diff;
    _fast_replace  "./packages/@n8n/task-runner/src/config/base-runner-config.ts"  "America/New_York"  "$LOCALTZ"; _fast_diff;
    _fast_replace  "./packages/frontend/@n8n/stores/src/useRootStore.ts"           "America/New_York"  "$LOCALTZ"; _fast_diff;
    _fast_replace  "./packages/nodes-base/nodes/Todoist/v2/TodoistV2.node.ts"      "America/New_York"  "$LOCALTZ"; _fast_diff;

    _fast_replace  "./packages/nodes-base/nodes/DateTime/V2/CurrentDateDescription.ts"      "America/New_York"  "$LOCALTZ"; _fast_diff;
    _fast_replace  "./packages/frontend/editor-ui/src/app/components/WorkflowSettings.vue"  "America/New_York"  "$LOCALTZ"; _fast_diff;

    echo;


exit 0;

