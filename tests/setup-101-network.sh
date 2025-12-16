#!/bin/bash

# Rede de containers
    # - Ja existe
    [ -d /sys/class/net/br-net-public ] && exit 0;

    # - Criar
    docker network create \
        -d bridge \
        \
        -o "com.docker.network.bridge.name"="br-net-public" \
        -o "com.docker.network.bridge.enable_icc"="true" \
        -o "com.docker.network.driver.mtu"="65495" \
        \
        --subnet 10.117.0.0/16 --gateway 10.117.255.254 \
        \
        --ipv6 \
        --subnet=2001:db8:10:117::/64 \
        --gateway=2001:db8:10:117::254 \
        \
        network_public;


exit 0;
