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

echo 'nameserver 192.168.122.1' > /etc/resolv.conf

sysctl -w net.ipv4.ip_forward=1

apt update
apt install isc-dhcp-relay -y

route add -net 10.76.2.0 netmask 255.255.255.128 gw 10.76.2.214

cat > /etc/default/isc-dhcp-relay << 'EOF'
SERVERS="10.76.2.202"
INTERFACES="eth0 eth1 eth2"
OPTIONS=""
EOF

service isc-dhcp-relay restart
