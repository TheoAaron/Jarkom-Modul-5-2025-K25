#!/bin/bash

cat > /etc/network/interfaces << 'EOF'
auto eth0
iface eth0 inet static
    address 10.76.2.210
    netmask 255.255.255.252

auto eth1
iface eth1 inet static
    address 10.76.2.213
    netmask 255.255.255.252

auto eth2
iface eth2 inet static
    address 10.76.1.1
    netmask 255.255.255.0
EOF

service networking restart

# Ensure IP addresses are assigned
ip addr add 10.76.2.210/30 dev eth0 2>/dev/null || true
ip addr add 10.76.2.213/30 dev eth1 2>/dev/null || true
ip addr add 10.76.1.1/24 dev eth2 2>/dev/null || true
ip link set eth0 up
ip link set eth1 up
ip link set eth2 up

echo 'nameserver 192.168.122.1' > /etc/resolv.conf

sysctl -w net.ipv4.ip_forward=1

apt update
apt install isc-dhcp-relay -y

# Ensure local subnet routing is correct
ip route add 10.76.2.208/30 dev eth0 2>/dev/null || true

# ===== ROUTING KE PELARGIR DAN DOWNSTREAM =====
route add -net 10.76.2.216 netmask 255.255.255.252 gw 10.76.2.214  # A3 (Pelargir-AnduinBanks)
route add -net 10.76.2.0 netmask 255.255.255.128 gw 10.76.2.214    # A4 (Gilgalad, Cirdan)
route add -net 10.76.2.220 netmask 255.255.255.252 gw 10.76.2.214  # A5 (Pelargir-Palantir)
route add default gw 10.76.2.209  # Default ke Osgiliath

cat > /etc/default/isc-dhcp-relay << 'EOF'
SERVERS="10.76.2.202"
INTERFACES="eth0 eth1 eth2"
OPTIONS=""
EOF

service isc-dhcp-relay restart