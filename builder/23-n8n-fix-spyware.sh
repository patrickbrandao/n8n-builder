#!/bin/bash

# Retirar todos os spywares do codigo

    # Incluir funcoes e variaveis
    . $(dirname $(readlink -f "$0"))/00-lib.sh;

    _echo_title "Removendo spywares, posthog e monitoramento remoto";

    # Dominio para substituir entradas
    [ "x$DOMAIN"          = "x" ] && DOMAIN="intranet";
    [ "x$FQDN_API"        = "x" ] && FQDN_API="api.$DOMAIN";
    [ "x$FQDN_CDN"        = "x" ] && FQDN_CDN="cdn.$DOMAIN";
    [ "x$FQDN_CDNRS"      = "x" ] && FQDN_CDNRS="cdn-rs.$DOMAIN";
    [ "x$FQDN_DOCS"       = "x" ] && FQDN_DOCS="docs.$DOMAIN";
    [ "x$FQDN_N8NIO"      = "x" ] && FQDN_N8NIO="n8nio.$DOMAIN";
    [ "x$FQDN_LICENSE"    = "x" ] && FQDN_LICENSE="license.$DOMAIN";
    [ "x$FQDN_POSTHOG"    = "x" ] && FQDN_POSTHOG="posthog.$DOMAIN";
    [ "x$FQDN_STORAGE"    = "x" ] && FQDN_STORAGE="storage.$DOMAIN";
    [ "x$FQDN_CREATORS"   = "x" ] && FQDN_CREATORS="creators.$DOMAIN";
    [ "x$FQDN_N8NCLOUD"   = "x" ] && FQDN_N8NCLOUD="cloud.$DOMAIN";
    [ "x$FQDN_TELEMETRY"  = "x" ] && FQDN_TELEMETRY="telemetry.$DOMAIN";
    [ "x$FQDN_APPPOSTHOG" = "x" ] && FQDN_APPPOSTHOG="app-posthog.$DOMAIN";
    [ "x$FQDN_ENTERPRISE" = "x" ] && FQDN_ENTERPRISE="enterprise.$DOMAIN";

    # Entrar no diretorio dos fontes:
    _cdfolder /opt/homebrew/n8n-current;

    #** utils.ts
    TARGET="./packages/frontend/@n8n/rest-api-client/src/utils.ts";
    _fast_replace  "$TARGET"   "n8n.cloud"                   "f01.$FQDN_N8NCLOUD"; #
    _fast_replace  "$TARGET"   "api.n8n.io"                  "f02.$FQDN_API";
    _old_diff      "$TARGET";


    #** urls.ts
    TARGET="./packages/frontend/editor-ui/src/app/constants/urls.ts";
    _fast_replace  "$TARGET" "n8n-community.typeform.com"  "f03.$FQDN_N8NIO/form";
    _fast_replace  "$TARGET" "stage-app.n8n.cloud/account" "f04.$FQDN_N8NCLOUD/account";
    _fast_replace  "$TARGET" "stage-app.n8n.cloud"         "f05.$FQDN_N8NCLOUD";
    _fast_replace  "$TARGET" "n8n.io/workflows"            "f06.$FQDN_N8NIO/workflows";
    _fast_replace  "$TARGET" "creators.n8n.io"             "f07.$FQDN_CREATORS";
    _fast_replace  "$TARGET" "n8n.io/pricing"              "f08.$FQDN_N8NIO/pricing";
    _fast_replace  "$TARGET" "app.n8n.cloud"               "f09.$FQDN_N8NCLOUD";
    _fast_replace  "$TARGET" "docs.n8n.io"                 "f0a.$FQDN_DOCS";
    _fast_replace  "$TARGET" "api.n8n.io"                  "f0b.$FQDN_API";
    _fast_diff;


    TARGET="./packages/frontend/editor-ui/src/app/api/workflow-webhooks.ts";
    _fast_replace  "$TARGET"     "api.n8n.io" "f0c.$FQDN_API";
    _fast_diff;


    TARGET="./packages/@n8n/config/test/config.test.ts";
    _fast_replace  "$TARGET"                   "telemetry.n8n.io" "f0d.$FQDN_TELEMETRY";
    _fast_replace  "$TARGET"                   "license.n8n.io"   "f0e.$FQDN_LICENSE";
    _fast_replace  "$TARGET"                   "docs.n8n.io"      "f0f.$FQDN_DOCS";
    _fast_replace  "$TARGET"                   "api.n8n.io"       "f0g.$FQDN_API";
    _fast_replace  "$TARGET"                   "us.i.posthog.com" "f0h.$FQDN_POSTHOG";
    _fast_diff;


    TARGET="./packages/@n8n/config/src/configs/version-notifications.config.ts";
    _backup "$TARGET";
    sed -i $SEDARG "s#docs.n8n.io#f0i.$FQDN_DOCS#"                           "$TARGET";
    sed -i $SEDARG "s#api.n8n.io/api/versions#f0j1.$FQDN_API/api/versions#"  "$TARGET";
    sed -i $SEDARG "s#api.n8n.io/api/whats#f0j2.$FQDN_API/api/whats#"        "$TARGET";
    _sed_diff;


    _fast_replace  "./packages/@n8n/constants/src/api.ts"                               "api.n8n.io"     "f0k.$FQDN_API"; _fast_diff;
    _fast_replace  "./packages/@n8n/config/src/configs/dynamic-banners.config.ts"       "api.n8n.io"     "f0l.$FQDN_API"; _fast_diff;
    _fast_replace  "./packages/@n8n/config/src/configs/templates.config.ts"             "api.n8n.io"     "f0m.$FQDN_API"; _fast_diff;

    # manter funcionamento da busca por community nodes
    _fast_replace  "./packages/cli/src/modules/community-packages/community-packages.service.ts" "api.n8n.io" "f0n.$FQDN_API"; _fast_diff;
    _fast_replace  "./packages/cli/src/modules/community-packages/community-node-types-utils.ts" "api.n8n.io" "f0o.$FQDN_API"; _fast_diff;
    # falta: remover envio do identificador da instalacao local

    _fast_replace  "./packages/frontend/editor-ui/src/app/plugins/telemetry/index.ts"   "cdn-rs.n8n.io"  "f0p.$FQDN_CDNRS"; _fast_diff;

    _fast_replace  "./packages/nodes-base/credentials/PostHogApi.credentials.ts"  "app.posthog.com" "f0q.$FQDN_APPPOSTHOG"; _fast_diff;

    _fast_replace  "./packages/@n8n/config/src/configs/diagnostics.config.ts"     "us.i.posthog.com" "f0r.$FQDN_POSTHOG"; _fast_diff;

    _fast_replace  "./packages/@n8n/config/src/configs/diagnostics.config.ts"     "telemetry.n8n.io" "f0s.$FQDN_TELEMETRY"; _fast_diff;


    _fast_replace  "./packages/cli/src/license/license.service.ts"                "enterprise.n8n.io" "f0t.$FQDN_ENTERPRISE"; _fast_diff;
    _fast_replace  "./packages/cli/test/integration/license.api.test.ts"          "enterprise.n8n.io" "f0u.$FQDN_ENTERPRISE"; _fast_diff;

    MSTORAGE="n8niostorageaccount.blob.core.windows.net";
    _fast_replace  "./packages/testing/playwright/workflows/Test_Template_1.json"                                     "$MSTORAGE" "f0v.$FQDN_STORAGE"; _fast_diff;
    _fast_replace  "./packages/testing/playwright/workflows/Ecommerce_starter_pack_template_collection.json"          "$MSTORAGE" "f0x.$FQDN_STORAGE"; _fast_diff;
    _fast_replace  "./packages/frontend/editor-ui/src/experiments/readyToRunWorkflowsV2/workflows/ai-workflow-v4.ts"  "$MSTORAGE" "f0z.$FQDN_STORAGE"; _fast_diff;

    _fast_replace  "./packages/testing/playwright/tests/ui/46-n8n-io-iframe.spec.ts"  "n8n.io/self-install" "f0w.$FQDN_N8NIO/self-install";  _fast_diff;
    _fast_replace  "./packages/frontend/editor-ui/src/app/components/Telemetry.vue"   "n8n.io/self-install" "f0y.$FQDN_N8NIO/self-install";  _fast_diff;

    echo;


exit 0

