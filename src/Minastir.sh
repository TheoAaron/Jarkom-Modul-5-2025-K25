#!/bin/bash

ip link set eth0 up
ip link set eth1 up
ip link set eth2 up

# Assign IP addresses
ip addr flush dev eth0 2>/dev/null
ip addr flush dev eth1 2>/dev/null
ip addr flush dev eth2 2>/dev/null
ip addr add 10.76.2.210/30 dev eth0
ip addr add 10.76.2.213/30 dev eth1
ip addr add 10.76.1.1/24 dev eth2

echo 1 > /proc/sys/net/ipv4/ip_forward
sysctl -w net.ipv4.ip_forward=1

cat > /etc/resolv.conf << 'EOF'
nameserver 192.168.122.1
nameserver 8.8.8.8
EOF

apt update
apt install isc-dhcp-relay -y

# Ensure local subnet routing is correct
ip route add 10.76.2.208/30 dev eth0 2>/dev/null || true

# ===== ROUTING KE PELARGIR DAN DOWNSTREAM =====
route add -net 10.76.2.216 netmask 255.255.255.252 gw 10.76.2.214  # A3 (Pelargir-AnduinBanks)
route add -net 10.76.2.0 netmask 255.255.255.128 gw 10.76.2.214    # A4 (Gilgalad, Cirdan)
route add -net 10.76.2.220 netmask 255.255.255.252 gw 10.76.2.214  # A5 (Pelargir-Palantir)

# ===== ROUTING KE MORIA BRANCH VIA OSGILIATH =====
route add -net 10.76.2.224 netmask 255.255.255.252 gw 10.76.2.209  # A7 (Osgiliath-Moria)
route add -net 10.76.2.228 netmask 255.255.255.252 gw 10.76.2.209  # A8 (Moria-IronHills)
route add -net 10.76.2.232 netmask 255.255.255.252 gw 10.76.2.209  # A9 (Moria-Wilderland)
route add -net 10.76.2.128 netmask 255.255.255.192 gw 10.76.2.209  # A10 (Durin)
route add -net 10.76.2.192 netmask 255.255.255.248 gw 10.76.2.209  # A11 (Khamul)

# ===== ROUTING KE RIVENDELL BRANCH VIA OSGILIATH =====
route add -net 10.76.2.236 netmask 255.255.255.252 gw 10.76.2.209  # A12 (Osgiliath-Rivendell)
route add -net 10.76.2.200 netmask 255.255.255.248 gw 10.76.2.209  # A13 (Vilya, Narya, DNS)

route add default gw 10.76.2.209  # Default ke Osgiliath

cat > /etc/default/isc-dhcp-relay << 'EOF'
SERVERS="10.76.2.202"
INTERFACES="eth0 eth1 eth2"
OPTIONS=""
EOF

service isc-dhcp-relay restart