#!/bin/bash

cat > /etc/network/interfaces << 'EOF'
auto eth0
iface eth0 inet static
address 10.76.2.222
netmask 255.255.255.252
gateway 10.76.2.221

auto eth1
iface eth1 inet static
address 10.76.2.225
netmask 255.255.255.252

auto eth2
iface eth2 inet static
address 10.76.2.229
netmask 255.255.255.252
EOF

service networking restart

route add -net 10.76.2.128 netmask 255.255.255.192 gw 10.76.2.230
route add -net 10.76.2.192 netmask 255.255.255.248 gw 10.76.2.230
