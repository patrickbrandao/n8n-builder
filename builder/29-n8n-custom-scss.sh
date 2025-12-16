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

    # - cor dos pontos do canvas
    sed -i $SEDARG 's#color--neutral-600:.*#color--neutral-600: hsl(196.32deg 85.13% 32.2%);#'  $PRIMITIVES;

    # - cor da barar de menu (esquerda e topo)
    sed -i $SEDARG 's#color--neutral-900:.*#color--neutral-900: hsl(229.05deg 69.62% 7.38%);#'  $PRIMITIVES;

    # - cor de fundo do canvas
    sed -i $SEDARG 's#color--neutral-950:.*#color--neutral-950: hsl(232.84deg 46.45% 6.34%);#'  $PRIMITIVES;

    # - cor do botao de execucao do workflow/trigger
    sed -i $SEDARG 's#color--orange-300:.*#color--orange-300: hsl(180.7deg 69.28% 45.84%);#'    $PRIMITIVES;

    # - cor da linha entre nodes com sucesso na transferencia
    sed -i $SEDARG 's#color--green-600:.*#--color--green-600: hsl(192.15deg 100% 69.66%);#'    $PRIMITIVES;
    # --color--green-600: hsl(147, 60%, 40%);
    # --color--green-600: hsl(192.15deg 100% 69.66%); < novo

    # - cor da borda do node com erro
    sed -i $SEDARG 's#canvas-node--border-color:.*#--canvas-node--border-color: hsl(0deg 100% 58.65%);#' $PRIMITIVES;
    # --canvas-node--border-color
    # --canvas-node--border-color: hsl(0deg 100% 58.65%); < mais vermelho

    # cor do icone de erro no node
    # var(--color--danger);  > mais vermelho: hsl(22.89deg 100% 43.26%);

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
    sed -i $SEDARG 's#--color--success:.*#--color--success: hsl(166.2deg 100% 28.53%);#'    $TOKENS; # verde-azul claro
    #sed -i $SEDARG 's#--color--success:.*#--color--success: hsl(143.65deg 100% 28.53%);#'  $TOKENS; # verde claro
    # --color--success: --color--success: var(--color-success, var(--color--green-600));  # verde claro (original)
    # --color--success: hsl(166.2deg 100% 28.53%);                                        # verde-azul claro (personalizado)
    # --canvas-node--border-color: var(--color-canvas-node-success-border-color, var(--color--success));
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


    # Fundo de borda animada novo
    RENDERCNDVUE="./packages/frontend/editor-ui/src/features/workflows/canvas/components/elements/nodes/render-types/CanvasNodeDefault.vue";
    _backup "$RENDERCNDVUE";
    sed -i $SEDARG 's#255, 109, 90#109, 210, 255#g' $RENDERCNDVUE;
    sed -i $SEDARG 's#border-rotate 1.5s#border-rotate 0.9s#g' $RENDERCNDVUE;
    sed -i $SEDARG 's#border-rotate 4.5s#border-rotate 2.1s#g' $RENDERCNDVUE;
    _sed_diff;



exit 0;

# Cor de no falho
# --color--danger: var(--color--red-400);
# --color--text--shade-1: var(--color--neutral-125);

# cor da linha entre nodes com json pinado
# --color--secondary: var(--color-secondary, var(--color--purple-600));

# cor do icone de erro no node
# var(--color--danger);  > mais vermelho: hsl(22.89deg 100% 43.26%);


# cor da linha que liga os nodes
# --color--foreground--shade-2

# node--icon--color--orange-red

# cor da linha entre nodes com sucesso na transferencia
# --color--success: var(--color-success, var(--color--green-600));
# --color--green-600: hsl(147, 60%, 40%);
# --color--green-600: hsl(192.15deg 100% 69.66%); < novo

# ./packages/frontend/@n8n/design-system/src/css/_tokens.scss:    --color--success: hsl(143.65deg 100% 28.53%);

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






# fundo animado que movimenta a borda
# original:
# conic-gradient(from var(--node--gradient-angle), rgb(255, 109, 90), rgb(255, 109, 90) 20%, rgba(255, 109, 90, 0.2) 35%, rgba(255, 109, 90, 0.2) 65%, rgb(255, 109, 90) 90%, rgb(255, 109, 90));

._running_y72lx_149::after, ._waiting_y72lx_149::after {
    content: "";
    position: absolute;
    inset: -3px;
    border-radius: 10px;
    z-index: -1;
    background: conic-gradient(
        from var(--node--gradient-angle), rgb(255, 109, 90), rgb(255, 109, 90) 20%, rgba(255, 109, 90, 0.2) 35%, rgba(255, 109, 90, 0.2) 65%, rgb(255, 109, 90) 90%, rgb(255, 109, 90)
    );


conic-gradient(from var(--node--gradient-angle), rgb(42 179 185), rgb(28 177 123) 20%, rgb(90 255 158 / 20%) 35%, rgb(90 255 176 / 20%) 65%, rgb(59 128 122) 90%, rgb(54 138 151));



._node_y72lx_123._success_y72lx_197 {
    --canvas-node--border-width: 2px;
    --canvas-node--border-color: var(--color-canvas-node-success-border-color, hsl(170.7deg 64.33% 52.94%));
}



after {
    animation: _border-rotate_y72lx_1 4.5s linear infinite;
}

# Codigo de gerador do fundo gradiente, https://jsfiddle.net/vzd3xapf/2/
#----------------------------------------------------------------------------
<html>
  <head>
  <style>
    body { background-color: #000; }


    #box {
      display: block;
      width: 200px;
      height: 200px;
      position: absolute;
      top: 100px;
      left: 100px;
      border-radius: 10px;
      border: 1px solid #333;
      background: conic-gradient(
        from 56.5653deg,
        rgba(109, 190, 255, 1),
        rgba(109, 190, 255, 1) 20%,
        rgba(109, 190, 255, 0.2) 35%,
        rgba(109, 190, 255, 0.2) 65%,
        rgba(109, 190, 255, 1) 110%,
        rgba(109, 190, 255, 1)
      );

      background: conic-gradient(
        from 156.5653deg,
        rgba(109, 210, 255, 1),
        rgba(109, 210, 255, 1) 10%,
        rgba(109, 210, 255, 0.1) 35%,
        rgba(109, 210, 255, 0.2) 65%,
        rgba(109, 210, 255, 1) 110%,
        rgba(109, 210, 255, 1)
      );


    }
  </style>

  </head>

  <body>
    <div id="box"></div>
  </body>
</html>
#----------------------------------------------------------------------------








