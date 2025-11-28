#!/bin/bash

cat > /etc/network/interfaces << 'EOF'
auto eth0
iface eth0 inet static
    address 10.76.2.230
    netmask 255.255.255.252
    gateway 10.76.2.229

auto eth1
iface eth1 inet static
    address 10.76.2.129
    netmask 255.255.255.192

auto eth2
iface eth2 inet static
    address 10.76.2.193
    netmask 255.255.255.248
EOF

service networking restart

echo 'nameserver 192.168.122.1' > /etc/resolv.conf

sysctl -w net.ipv4.ip_forward=1

apt update
apt install isc-dhcp-relay -y

cat > /etc/default/isc-dhcp-relay << 'EOF'
SERVERS="10.76.2.202"
INTERFACES="eth0 eth1 eth2"
OPTIONS=""
EOF

service isc-dhcp-relay restart
