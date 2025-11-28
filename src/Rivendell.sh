#!/bin/bash

cat > /etc/network/interfaces << 'EOF'
auto eth0
iface eth0 inet static
    address 10.76.2.234
    netmask 255.255.255.252
    gateway 10.76.2.233

auto eth1
iface eth1 inet static
    address 10.76.2.201
    netmask 255.255.255.248
EOF

ifdown eth0 && ifup eth0
ifdown eth1 && ifup eth1

echo 'nameserver 192.168.122.1' > /etc/resolv.conf

sysctl -w net.ipv4.ip_forward=1

apt update
apt install isc-dhcp-relay -y

cat > /etc/default/isc-dhcp-relay << 'EOF'
SERVERS="10.76.2.202"
INTERFACES="eth0 eth1"
OPTIONS=""
EOF

service isc-dhcp-relay restart