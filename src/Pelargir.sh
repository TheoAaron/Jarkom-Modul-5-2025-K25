#!/bin/bash

cat > /etc/network/interfaces << 'EOF'
auto eth0
iface eth0 inet static
address 10.76.2.210
netmask 255.255.255.252
gateway 10.76.2.209

auto eth1
iface eth1 inet static
address 10.76.2.213
netmask 255.255.255.252

auto eth2
iface eth2 inet static
address 10.76.2.217
netmask 255.255.255.252
EOF

service networking restart

route add -net 10.76.2.0 netmask 255.255.255.128 gw 10.76.2.214
