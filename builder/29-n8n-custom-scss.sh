#!/bin/bash

# Personalizar CORES NO ESTILO CSS

    # Incluir funcoes e variaveis
    . $(dirname $(readlink -f "$0"))/00-lib.sh;

    _echo_title "Aplicando customizacao de estilo CSS / SCSS";

    # formato de arquivo backup inicial
    BCKEXT="ocss";

    # Entrar no diretorio dos fontes:
    _cdfolder /opt/homebrew/n8n-current;


    # PRIMITIVES
    PRIMITIVES="./packages/frontend/@n8n/design-system/src/css/_primitives.scss";
    _backup "$PRIMITIVES";
    # - cor de fundo do canvas
    sed -i $SEDARG 's#color--neutral-950:.*#color--neutral-950: hsl(232.84deg 46.45% 6.34%);#' $PRIMITIVES;

    # - cor dos pontos do canvas
    sed -i $SEDARG 's#color--neutral-600:.*#color--neutral-600: hsl(196.32deg 85.13% 32.2%);#'  $PRIMITIVES;

    # - cor da barar de menu (esquerda e topo)
    sed -i $SEDARG 's#color--neutral-900:.*#color--neutral-900: hsl(229.05deg 69.62% 7.38%);#' $PRIMITIVES;

    # - cor do botao de execucao do workflow/trigger
    sed -i $SEDARG 's#color--orange-300:.*#color--orange-300: hsl(209.22deg 84.33% 15.42%);#'  $PRIMITIVES;

    # sed -i $SEDARG 's#color--orange-400:.*#color--orange-400: hsl(211.39deg 74.15% 30.61%);#'  $PRIMITIVES;
    # sed -i $SEDARG 's#color--orange-alpha-500:.*#color--orange-alpha-500: hsl(122.16deg 43.68% 47.56% / 50%);#' $PRIMITIVES;
    # sed -i $SEDARG 's#color--neutral-700:.*#color--neutral-700: hsl(211deg 49% 28% / 40%);#'  $PRIMITIVES;
    # sed -i $SEDARG 's#color--neutral-850:.*#--color--neutral-850: hsl(0deg 0% 0%);#'  $PRIMITIVES;
    _sed_diff;


    # TOKENS
    TOKENS="./packages/frontend/@n8n/design-system/src/css/_tokens.scss";
    _backup "$TOKENS";
    # - cor do node em execucao
    sed -i $SEDARG 's#node--border-color--running.*#node--border-color--running: hsl(209.22deg 89.88% 64.64%);#' $TOKENS;
    # - node tools de agentes
    sed -i $SEDARG 's#--node-type--supplemental--color--h:.*#node-type--supplemental--color--h: 0deg;#' $TOKENS;
    sed -i $SEDARG 's#--node-type--supplemental--color--s:.*#node-type--supplemental--color--s: 0%;#'   $TOKENS;
    sed -i $SEDARG 's#--node-type--supplemental--color--l:.*#node-type--supplemental--color--l: 0%;#'   $TOKENS;
    # - borda do node executado com sucesso
    sed -i $SEDARG 's#--color--success:.*#--color--success: hsl(143.65deg 100% 28.53%);#'   $TOKENS;

    # - icone giratorio no node em execucao (estragou outros textos)
    #sed -i $SEDARG 's#color--primary--h:.*#color--primary--h: 209;#' $TOKENS;
    #sed -i $SEDARG 's#color--primary--s:.*#color--primary--s: 79%;#' $TOKENS;
    #sed -i $SEDARG 's#color--primary--l:.*#color--primary--l: 79%;#' $TOKENS;

    _sed_diff;


    # ANIMATION
    ICONVUE="./packages/frontend/@n8n/design-system/src/components/N8nIcon/Icon.vue";
    _backup "$ICONVUE";
    # - velocidade de giro na animacao do node executando
    sed -i $SEDARG 's#spin 1s linear infinite#spin 0.5s linear infinite#' $ICONVUE;
    _sed_diff;


exit 0;

# cor da borda do node com erro
# --canvas-node--border-color
# --canvas-node--border-color: hsl(0deg 100% 58.65%); < mais vermelho


# cor do icone de erro no node
# var(--color--danger);  > mais vermelho: hsl(22.89deg 100% 43.26%);


# cor da linha que liga os nodes
# --color--foreground--shade-2


    # Arquivos:
    #    ./packages/frontend/@n8n/design-system/src/css/_primitives.scss;
    #    ./packages/frontend/@n8n/design-system/src/css/_tokens.dark.scss
    #    ./packages/frontend/@n8n/design-system/src/css/_tokens.scss

    # BACKUP
    PRIMITIVES=./packages/frontend/@n8n/design-system/src/css/_primitives.scss;
    _backup "$PRIMITIVES";

    DARKSCSS=./packages/frontend/@n8n/design-system/src/css/_tokens.dark.scss;
    _backup "$DARKSCSS";


    #- COR DE FUNDO DARK DO PALCO
    # original......: --p-gray-820: hsl(var(--h-gray), 1%, 18%);
    # alterar para..: hsl(220deg 84.65% 9.26%); >>  --p-gray-820: hsl(220deg 84.65% 9.26%);
    sed -i $SEDARG 's/--p-gray-820.*/--p-gray-820: hsl(220deg 84.65% 9.26%);/g' $PRIMITIVES;
    _sed_diff;

    #- COR DE FUNDO DARK DA BARRA SUPERIOR E LATERAL
    # original......: --p-gray-740: hsl(var(--h-gray), 2%, 26%);
    # alterar para..: hsl(217.55deg 66.48% 21.24%); >>  --p-gray-740: hsl(217.55deg 66.48% 21.24%);
    sed -i $SEDARG 's/--p-gray-740.*/--p-gray-740: hsl(217.55deg 66.48% 21.24%);/g' $PRIMITIVES;
    _sed_diff;

    #- COR DE BORDA DE NODES COM ERROS
    # original......: --p-color-alt-h-310: hsl(355, 100%, 69%);
    # alterar para..: hsl(35.21deg 80.49% 44.61%) >>  --p-color-alt-h-310: hsl(355, 100%, 69%);
    sed -i $SEDARG 's/--p-color-alt-h-310.*/--p-color-alt-h-310: hsl(35.21deg 80.49% 44.61%);/g' $PRIMITIVES;
    _sed_diff;

    #- COR DE FUNDO DOS TOOLS DE IA
    # original......: ... usa 3 variaveis externas
    #    --node-type-supplemental-color-h: 235;
    #    --node-type-supplemental-color-s: 13%;
    #    --node-type-background-l: 20%;
    # alterar para..: hsl(0deg 0% 0%) >>  --node-type-supplemental-background: hsl(0deg 0% 0%)
    SPT='node-type-supplemental-background';
    sed -i $SEDARG '/supplemental-background/,+4{/supplemental-background/!d;}; /supplemental-background/a\       0deg 0% 0%);' $DARKSCSS;
    _sed_diff;

    #- COR DE FUNDO DO MENU SELECIONADO A ESQUERDA
    # original......: --p-gray-670: hsl(var(--h-gray), 2%, 33%);
    # alterar para..: hsl(220deg 42.43% 44.89%) >>  --p-gray-670: hsl(220deg 42.43% 44.89%)
    sed -i $SEDARG 's/--p-gray-670.*/--p-gray-670: hsl(220deg 42.43% 44.89%);/g' $PRIMITIVES;
    _sed_diff;

    echo;




