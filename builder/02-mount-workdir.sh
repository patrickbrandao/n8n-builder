#!/bin/sh

# Montar workdir, se houver ramdisk local
    # Incluir funcoes e variaveis
    . $(dirname $(readlink -f "$0"))/00-lib.sh;

    _echo_title "Preparando pasta de trabalho /opt/homebrew";
    mkdir -p /opt/homebrew;

    # Reiniciar para limpar:
    _echo_task "Reiniciando ramdisk";
    service ramdisk stop;
    service ramdisk start;
    echo;

exit 0;
