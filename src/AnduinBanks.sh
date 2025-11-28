#!/bin/bash

cat > /etc/network/interfaces << 'EOF'
auto eth0
iface eth0 inet static
address 10.76.2.214
netmask 255.255.255.252
gateway 10.76.2.213

auto eth1
iface eth1 inet static
address 10.76.2.1
netmask 255.255.255.128
EOF

service networking restart

apt update
apt install isc-dhcp-relay -y

cat > /etc/default/isc-dhcp-relay << 'EOF'
SERVERS="10.76.2.202"
INTERFACES="eth0 eth1"
OPTIONS=""
EOF

service isc-dhcp-relay restart
