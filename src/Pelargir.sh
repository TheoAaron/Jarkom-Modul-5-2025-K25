#!/bin/bash

cat > /etc/network/interfaces << 'EOF'
auto eth0
iface eth0 inet static
    address 10.76.2.214
    netmask 255.255.255.252

auto eth1
iface eth1 inet static
    address 10.76.2.217
    netmask 255.255.255.252

auto eth2
iface eth2 inet static
    address 10.76.2.221
    netmask 255.255.255.252
EOF

service networking restart

# Ensure IP addresses are assigned
ip addr add 10.76.2.214/30 dev eth0 2>/dev/null || true
ip addr add 10.76.2.217/30 dev eth1 2>/dev/null || true
ip addr add 10.76.2.221/30 dev eth2 2>/dev/null || true
ip link set eth0 up
ip link set eth1 up
ip link set eth2 up

echo 'nameserver 192.168.122.1' > /etc/resolv.conf

sysctl -w net.ipv4.ip_forward=1

apt update
apt install isc-dhcp-relay -y

# ===== ROUTING KE ANDUINBANKS =====
route add -net 10.76.2.0 netmask 255.255.255.128 gw 10.76.2.218  # A4 (Gilgalad, Cirdan)
route add default gw 10.76.2.213  # Default ke Minastir

cat > /etc/default/isc-dhcp-relay << 'EOF'
SERVERS="10.76.2.202"
INTERFACES="eth0 eth1 eth2"
OPTIONS=""
EOF

service isc-dhcp-relay restart