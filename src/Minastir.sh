#!/bin/bash

cat > /etc/network/interfaces << 'EOF'
auto eth0
iface eth0 inet static
address 10.76.2.206
netmask 255.255.255.252
gateway 10.76.2.205

auto eth1
iface eth1 inet static
address 10.76.2.209
netmask 255.255.255.252

auto eth2
iface eth2 inet static
address 10.76.1.1
netmask 255.255.255.0
EOF

service networking restart

route add -net 10.76.2.212 netmask 255.255.255.252 gw 10.76.2.210
route add -net 10.76.2.0 netmask 255.255.255.128 gw 10.76.2.210
route add -net 10.76.2.216 netmask 255.255.255.252 gw 10.76.2.210

apt update
apt install isc-dhcp-relay -y

cat > /etc/default/isc-dhcp-relay << 'EOF'
SERVERS="10.76.2.202"
INTERFACES="eth0 eth1 eth2"
OPTIONS=""
EOF

service isc-dhcp-relay restart
