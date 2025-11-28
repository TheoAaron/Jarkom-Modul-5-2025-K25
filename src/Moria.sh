#!/bin/bash

cat > /etc/network/interfaces << 'EOF'
auto eth0
iface eth0 inet static
    address 10.76.2.226
    netmask 255.255.255.252
    gateway 10.76.2.225

auto eth1
iface eth1 inet static
    address 10.76.2.233
    netmask 255.255.255.252

auto eth2
iface eth2 inet static
    address 10.76.2.229
    netmask 255.255.255.252
EOF

ifdown eth0 && ifup eth0
ifdown eth1 && ifup eth1
ifdown eth2 && ifup eth2

echo 'nameserver 192.168.122.1' > /etc/resolv.conf

sysctl -w net.ipv4.ip_forward=1

# ===== ROUTING KE WILDERLAND =====
route add -net 10.76.2.128 netmask 255.255.255.192 gw 10.76.2.230  # A10 (Durin)
route add -net 10.76.2.192 netmask 255.255.255.248 gw 10.76.2.230  # A11 (Khamul)

apt update
apt install isc-dhcp-relay -y

cat > /etc/default/isc-dhcp-relay << 'EOF'
SERVERS="10.76.2.202"
INTERFACES="eth0 eth1 eth2"
OPTIONS=""
EOF

service isc-dhcp-relay restart