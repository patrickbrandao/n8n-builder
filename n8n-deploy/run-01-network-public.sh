docker network create \
    -d bridge \
    \
    -o "com.docker.network.bridge.name"="br-net-public" \
    -o "com.docker.network.bridge.enable_icc"="true" \
    -o "com.docker.network.driver.mtu"="1500" \
    \
    --subnet 10.249.0.0/16 --gateway 10.249.255.254 \
    \
    network_public;
