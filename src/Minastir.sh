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

ifdown eth0 && ifup eth0
ifdown eth1 && ifup eth1
ifdown eth2 && ifup eth2

echo 'nameserver 192.168.122.1' > /etc/resolv.conf

sysctl -w net.ipv4.ip_forward=1

# ===== ROUTING KE PELARGIR DAN DOWNSTREAM =====
route add -net 10.76.2.212 netmask 255.255.255.252 gw 10.76.2.210  # A3 (Pelargir-AnduinBanks)
route add -net 10.76.2.0 netmask 255.255.255.128 gw 10.76.2.210    # A4 (Gilgalad, Cirdan)
route add -net 10.76.2.216 netmask 255.255.255.252 gw 10.76.2.210  # A5 (Pelargir-Palantir)

apt update
apt install isc-dhcp-relay -y

cat > /etc/default/isc-dhcp-relay << 'EOF'
SERVERS="10.76.2.202"
INTERFACES="eth0 eth1 eth2"
OPTIONS=""
EOF

service isc-dhcp-relay restart