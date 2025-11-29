#!/bin/bash

cat > /etc/network/interfaces << 'EOF'
auto eth0
iface eth0 inet static
    address 10.76.2.226
    netmask 255.255.255.252

auto eth1
iface eth1 inet static
    address 10.76.2.229
    netmask 255.255.255.252

auto eth2
iface eth2 inet static
    address 10.76.2.233
    netmask 255.255.255.252
EOF

service networking restart

# Ensure IP addresses are assigned
ip addr add 10.76.2.226/30 dev eth0 2>/dev/null || true
ip addr add 10.76.2.229/30 dev eth1 2>/dev/null || true
ip addr add 10.76.2.233/30 dev eth2 2>/dev/null || true
ip link set eth0 up
ip link set eth1 up
ip link set eth2 up

echo 'nameserver 192.168.122.1' > /etc/resolv.conf

sysctl -w net.ipv4.ip_forward=1

apt update
apt install isc-dhcp-relay -y

# ===== ROUTING KE WILDERLAND =====
route add -net 10.76.2.128 netmask 255.255.255.192 gw 10.76.2.234  # A10 (Durin)
route add -net 10.76.2.192 netmask 255.255.255.248 gw 10.76.2.234  # A11 (Khamul)
route add default gw 10.76.2.225  # Default ke Osgiliath

cat > /etc/default/isc-dhcp-relay << 'EOF'
SERVERS="10.76.2.202"
INTERFACES="eth0 eth1 eth2"
OPTIONS=""
EOF

service isc-dhcp-relay restart