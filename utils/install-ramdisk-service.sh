#!/bin/bash

# Criar arquivos com variáveis de ambiente padrão:
(
    echo 'RAMDISK_SIZE=16';
    echo 'RAMDISK_MOUNT=yes';
    echo 'RAMDISK_FS=ext4';
    echo 'RAMDISK_DIR=/opt/homebrew';
    echo 'RAMDISK_OPTIONS=""';
) > /etc/default/ramdisk;

# Criar diretorios de scripts:
mkdir -p /etc/ramdisk-pre-up.d;   chmod 755 /etc/ramdisk-pre-up.d;
mkdir -p /etc/ramdisk-up.d;       chmod 755 /etc/ramdisk-up.d;
mkdir -p /etc/ramdisk-pre-down.d; chmod 755 /etc/ramdisk-pre-down.d;
mkdir -p /etc/ramdisk-down.d;     chmod 755 /etc/ramdisk-down.d;

# Script para obter variáveis de ambiente com valores default
(
    echo '#!/bin/bash';
    echo;
    echo '[ -f /etc/default/ramdisk ] && . /etc/default/ramdisk;';
    echo;
    echo '# Carregar defautls';
    echo '[ "x$RAMDISK_SIZE"    = "x" ] && RAMDISK_SIZE=8;';
    echo '[ "x$RAMDISK_MOUNT"   = "x" ] && RAMDISK_MOUNT=yes;';
    echo '[ "x$RAMDISK_FS"      = "x" ] && RAMDISK_FS=ext4;';
    echo '[ "x$RAMDISK_DIR"     = "x" ] && RAMDISK_DIR="/ram";';
    echo '[ "x$RAMDISK_OPTIONS" = "x" ] && RAMDISK_OPTIONS="fast";';
    echo 'RAMDISK_BSIZE=$((RAMDISK_SIZE * 1024 * 1024));';
    echo 'RAMDISK_KARG="options brd rd_nr=1 max_part=3 rd_size=$RAMDISK_BSIZE";';
    echo;
    echo '# Exportar para ambiente';
    echo 'export RAMDISK_SIZE="$RAMDISK_SIZE";';
    echo 'export RAMDISK_MOUNT="$RAMDISK_MOUNT";';
    echo 'export RAMDISK_DIR="$RAMDISK_DIR";';
    echo 'export RAMDISK_FS="$RAMDISK_FS";';
    echo 'export RAMDISK_OPTIONS="$RAMDISK_OPTIONS";';
    echo 'export RAMDISK_BSIZE="$RAMDISK_BSIZE";';
    echo 'export RAMDISK_KARG="$RAMDISK_KARG";';
    echo;
) > /usr/local/sbin/ramdisk-env;
chmod +x /usr/local/sbin/ramdisk-env;

# Script para executar os scripts do evento
(
    echo '#!/bin/bash';
    echo;
    echo '. /usr/local/sbin/ramdisk-env;';
    echo;
    echo 'EVDIR="/etc/ramdisk-$1.d";';
    echo '[ -d "$EVDIR" ] || exit 1;';
    echo 'cd "$EVDIR" || exit 2;';
    echo;
    echo 'for script in $EVDIR/*; do';
    echo '    if [ -x "$script" ]; then';
    echo '        "$script" || true;';
    echo '    fi;';
    echo 'done;';
    echo;
) > /usr/local/sbin/ramdisk-run-scripts;
chmod +x /usr/local/sbin/ramdisk-run-scripts;

# Script para particionar ramdisk
(
    echo '#!/bin/bash';
    echo;
    echo '# Criar partição padrão GPT no RAMDISK';
    echo '# - Tipos de particoes';
    echo 'GUID_BIOS="21686148-6449-6E6F-744E-656564454649";  # bios boot';
    echo 'GUID_ESP="C12A7328-F81F-11D2-BA4B-00A0C93EC93B";   # esp efi/uefi';
    echo 'GUID_LINUX="0FC63DAF-8483-4772-8E79-3D69D8477DE4"; # linux (root)';
    echo;
    echo '# Apagar primeiros setores (capricho):';
    echo 'dd if=/dev/zero of=/dev/ram0 bs=512 count=2048 oflag=direct 2>/dev/null;';
    echo;
    echo '# 1. Particionar GPT:';
    echo 'parted /dev/ram0 --script -- mklabel gpt 2>/dev/null;';
    echo;
    echo '# 2. Criar partição 1 - BIOS boot (setores 34 a 2047)';
    echo 'parted /dev/ram0 --script -- mkpart primary 34s 2047s 2>/dev/null;';
    echo 'parted /dev/ram0 --script -- type 1 "$GUID_BIOS";';
    echo;
    echo '# 3. Criar partição 2 - EFI System (setores 2048 a 2099199 = 1GB)';
    echo 'parted /dev/ram0 --script -- mkpart primary fat32 2048s 2099199s;';
    echo 'parted /dev/ram0 --script -- type 2 "$GUID_ESP";';
    echo;
    echo '# 4. Criar partição 3 - Linux LVM (setores 2099200 a 20971486 = 9.5GB)';
    echo 'parted /dev/ram0 --script -- mkpart primary 2099200s '100%';';
    echo 'parted /dev/ram0 --script -- type 3 "$GUID_LINUX";';
    echo;
) > /usr/local/sbin/ramdisk-part-gpt;
chmod +x /usr/local/sbin/ramdisk-part-gpt;

# Fazer setup do sistema de arquivos no ramdisk
(
    echo '#!/bin/bash';
    echo;
    echo '. /usr/local/sbin/ramdisk-env;';
    echo;
    echo '# Dispositivo de blocos alvo';
    echo 'BDEV="/dev/ram0p3";';
    echo '[ -e "$BDEV" ] || { echo "$BDEV not found"; BDEV="/dev/ram0"; };';
    echo '[ -e "$BDEV" ] || { echo "$BDEV not found"; exit 11; };';
    echo;
    echo '# Montagem desativa, deixar normal';
    echo '[ "$RAMDISK_MOUNT" = "yes" ] || { echo "skip mount"; exit 0; };';
    echo;
    echo '# Programa formatador:';
    echo '[ -x "/usr/sbin/mkfs.$RAMDISK_FS" ] || {';
    echo '    echo "/usr/sbin/mkfs.$RAMDISK_FS not found";';
    echo '    exit 12;';
    echo '};';
    echo;
    echo '# Opcoes de formatacao';
    echo 'MKFS_OPTION="";';
    echo 'if [ "$RAMDISK_OPTIONS" = "fast" -a "$RAMDISK_FS" = "ext4" ]; then';
    echo '    MKFS_OPTION="-O ^has_journal";';
    echo 'fi;';
    echo;
    echo '# Criar diretorio';
    echo '[ -d "$RAMDISK_DIR" ] || mkdir -p "$RAMDISK_DIR";';
    echo;
    echo '# Se ja estiver montado, ignorar, nao montar overlay';
    echo 'egrep -q "$RAMDISK_DIR" /proc/mounts && {';
    echo '    echo "pre-mounted $RAMDISK_DIR";';
    echo '    exit 0;';
    echo '};';
    echo;
    echo '# Formatar:';
    echo 'echo "Format: mkfs.$RAMDISK_FS $MKFS_OPTION $BDEV";';
    echo 'echo "y" | /usr/sbin/mkfs.$RAMDISK_FS $MKFS_OPTION $BDEV || {';
    echo '    echo "Format: failure mkfs.$RAMDISK_FS $MKFS_OPTION $BDEV";';
    echo '    # Tentar formatar novamente:';
    echo '    echo "Format: mkfs.$RAMDISK_FS $BDEV";';
    echo '    echo "y" | /usr/sbin/mkfs.$RAMDISK_FS $BDEV || {';
    echo '        echo "Format: failure mkfs.$RAMDISK_FS $BDEV";';
    echo '        exit 13;';
    echo '    };';
    echo '};';
    echo;
    echo '# Montar RD no diretorio';
    echo 'WORKS=0;';
    echo 'MOUNT="mount -t ext4 $BDEV $RAMDISK_DIR";';
    echo 'echo "Mounting: $BDEV on $RAMDISK_DIR";';
    echo 'if [ "$RAMDISK_OPTIONS" = "fast" -a "$RAMDISK_FS" = "ext4" ]; then';
    echo '    # Modo optimizado';
    echo '    OPT_BASIC="noatime,nodiratime,relatime";';
    echo '    OPT_TRY01="nodiscard,noinit_itable,commit=3600,nobarrier";';
    echo '    OPT_TRY02="nodiscard,noinit_itable,commit=3600";';
    echo '    OPT_TRY03="nodiscard,noinit_itable,nobarrier";';
    echo '    OPT_TRY04="nodiscard,noinit_itable,nodelalloc";';
    echo '    OPT_TRY05="nodiscard,nodelalloc";';
    echo '    OPT_TRY06="nodiscard,noinit_itable";';
    echo '    OPT_TRY07="nodiscard,nobarrier";';
    echo '    OPT_TRY08="nodiscard";';
    echo '    # Tentar opcoes de montagem';
    echo '    [ "$WORKS" = "0" ] && $MOUNT -o $OPT_BASIC,$OPT_TRY01 2>/dev/null;';
    echo '    [ "$?" = "0" ] && WORKS="1";';
    echo '    [ "$WORKS" = "0" ] && $MOUNT -o $OPT_BASIC,$OPT_TRY01 2>/dev/null;';
    echo '    [ "$?" = "0" ] && WORKS="2";';
    echo '    [ "$WORKS" = "0" ] && $MOUNT -o $OPT_BASIC,$OPT_TRY02 2>/dev/null;';
    echo '    [ "$?" = "0" ] && WORKS="3";';
    echo '    [ "$WORKS" = "0" ] && $MOUNT -o $OPT_BASIC,$OPT_TRY03 2>/dev/null;';
    echo '    [ "$?" = "0" ] && WORKS="4";';
    echo '    [ "$WORKS" = "0" ] && $MOUNT -o $OPT_BASIC,$OPT_TRY04 2>/dev/null;';
    echo '    [ "$?" = "0" ] && WORKS="5";';
    echo '    [ "$WORKS" = "0" ] && $MOUNT -o $OPT_BASIC,$OPT_TRY05 2>/dev/null;';
    echo '    [ "$?" = "0" ] && WORKS="6";';
    echo '    [ "$WORKS" = "0" ] && $MOUNT -o $OPT_BASIC,$OPT_TRY06 2>/dev/null;';
    echo '    [ "$?" = "0" ] && WORKS="7";';
    echo '    [ "$WORKS" = "0" ] && $MOUNT -o $OPT_BASIC,$OPT_TRY07 2>/dev/null;';
    echo '    [ "$?" = "0" ] && WORKS="8";';
    echo '    [ "$WORKS" = "0" ] && $MOUNT -o $OPT_BASIC,$OPT_TRY08 2>/dev/null;';
    echo '    [ "$?" = "0" ] && WORKS="9";';
    echo '    [ "$WORKS" = "0" ] && $MOUNT -o $OPT_BASIC 2>/dev/null;';
    echo '    [ "$?" = "0" ] && WORKS="10";';
    echo '    [ "$WORKS" = "0" ] && $MOUNT 2>/dev/null;';
    echo '    [ "$?" = "0" ] && WORKS="11";';
    echo;
    echo 'else';
    echo '    # Modo normal';
    echo '    [ "$WORKS" = "0" ] && $MOUNT 2>/dev/null;';
    echo '    [ "$?" = "0" ] && WORKS="11";';
    echo 'fi;';
    echo;
    echo '# Ajuste de permissao';
    echo 'chmod 1777 "$RAMDISK_DIR"';
    echo;
    echo '# Testar se a montagem base funcionou';
    echo 'if [ "$WORKS" = "0" ]; then';
    echo '    echo "Mounting: failure on $MOUNT";';
    echo '    exit 14;';
    echo 'fi;';
    echo;
) > /usr/local/sbin/ramdisk-fs-setup;
chmod +x /usr/local/sbin/ramdisk-fs-setup;

# Script para iniciar ramdisk
(
    echo '#!/bin/bash';
    echo;
    echo '. /usr/local/sbin/ramdisk-env;';
    echo;
    echo '# Setup';
    echo '[ -f /etc/modules-load.d/brd.conf ] || {';
    echo '    echo "brd" > /etc/modules-load.d/brd.conf;';
    echo '};';
    echo 'CURRENT_KARG=$(head -1 /etc/modprobe.d/brd.conf);';
    echo '[ "$RAMDISK_KARG" = "$CURRENT_KARG" ] || {';
    echo '    echo "$RAMDISK_KARG" > /etc/modprobe.d/brd.conf;';
    echo '};';
    echo;
    echo '# Carregar modulo';
    echo '_modprobe(){';
    echo '    echo "kernel: load brd";';
    echo '    modprobe brd;';
    echo '};';
    echo 'egrep -q '^brd' /proc/modules || _modprobe;';
    echo;
    echo '# Detectar RD';
    echo 'BDFOUND=0;';
    echo 'for i in 1 2 3 4 5 6 7 8 9 10; do';
    echo '    [ -e /dev/ram0 ] && { BDFOUND=1; break; };';
    echo '    echo "kernel: wait brd";';
    echo '    sleep 0.1;';
    echo 'done;';
    echo 'if [ "$BDFOUND" = "0" ]; then';
    echo '    echo "kernel: RamDisk /dev/ram0 not found";';
    echo '    exit 11;';
    echo 'fi;';
    echo;
    echo '# Executar pre-up scripts';
    echo '/usr/local/sbin/ramdisk-run-scripts "pre-up";';
    echo;
    echo '# Particionar ramdisk';
    echo '/usr/local/sbin/ramdisk-part-gpt;';
    echo;
    echo '# Formatar e montar';
    echo '/usr/local/sbin/ramdisk-fs-setup || exit 11;';
    echo;
    echo '# Executar up scripts';
    echo '/usr/local/sbin/ramdisk-run-scripts "up";';
    echo;
) > /usr/local/sbin/ramdisk-start;
chmod +x /usr/local/sbin/ramdisk-start;

# Script para parar ramdisk
(
    echo '#!/bin/bash';
    echo;
    echo '. /usr/local/sbin/ramdisk-env;';
    echo;
    echo '# Desmontar apenas se estiver montado';
    echo 'egrep -q "$RAMDISK_DIR" /proc/mounts && {';
    echo '    # Executar pre-down scripts';
    echo '    echo "scripts: pre-down";';
    echo '    /usr/local/sbin/ramdisk-run-scripts "pre-down";';
    echo;
    echo '    # Desmontar';
    echo '    echo "umount $RAMDISK_DIR";';
    echo '    sync;';
    echo '    umount /dev/ram0p3 2>/dev/null; sn="$?";';
    echo '    [ "$sn" = "0" ] || {';
    echo '        for t in 1 2 3; do';
    echo '            echo "umount $RAMDISK_DIR - try $t";';
    echo '            umount    /dev/ram0p3 2>/dev/null && break;';
    echo '            umount -f /dev/ram0p3 2>/dev/null && break;';
    echo '            sleep 0.1;';
    echo '        done;';
    echo '    };';
    echo;
    echo '    # Executar down scripts';
    echo '    echo "scripts: down";';
    echo '    /usr/local/sbin/ramdisk-run-scripts "down";';
    echo;
    echo '};';
    echo;
    echo '# Descarregar ramdisk do kernel para novos parametros';
    echo 'CURRENT_KARG=$(head -1 /etc/modprobe.d/brd.conf);';
    echo '[ "$RAMDISK_KARG" = "$CURRENT_KARG" ] || {';
    echo '    egrep -q "brd" /proc/modules && {';
    echo '        echo "kernel: unload brd";';
    echo '        rmmod brd 2>/dev/null;';
    echo '    };';
    echo '};';
    echo;
) > /usr/local/sbin/ramdisk-stop;
chmod +x /usr/local/sbin/ramdisk-stop;

# Unity de servico no SystemD
(
    echo '[Unit]';
    echo 'Description=RAM Disk Service';
    echo 'DefaultDependencies=no';
    echo 'After=local-fs-pre.target';
    echo 'Before=local-fs.target';
    echo 'Before=NetworkManager.service';
    echo 'Before=network-pre.target';
    echo '';
    echo '[Service]';
    echo 'Type=oneshot';
    echo 'RemainAfterExit=yes';
    echo 'EnvironmentFile=/etc/default/ramdisk';
    echo 'ExecStart=/usr/local/sbin/ramdisk-start';
    echo 'ExecStop=/usr/local/sbin/ramdisk-stop';
    echo 'TimeoutSec=60';
    echo '';
    echo '[Install]';
    echo 'WantedBy=local-fs.target';
) > /etc/systemd/system/ramdisk.service;

# Atualizar systemd:
systemctl daemon-reload;


