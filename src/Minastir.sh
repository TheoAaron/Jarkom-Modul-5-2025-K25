#!/bin/bash

# Enable IP forwarding first
echo 1 > /proc/sys/net/ipv4/ip_forward
sysctl -w net.ipv4.ip_forward=1

# Bring up interfaces
ip link set eth0 up
ip link set eth1 up
ip link set eth2 up

# Flush and assign IP addresses
ip addr flush dev eth0 2>/dev/null
ip addr flush dev eth1 2>/dev/null
ip addr flush dev eth2 2>/dev/null
ip addr add 10.76.2.210/30 dev eth0  # ke Osgiliath
ip addr add 10.76.1.1/24 dev eth1    # ke Elendil & Isildur
ip addr add 10.76.2.213/30 dev eth2  # ke Pelargir

# Set default route FIRST (paling penting untuk internet)
ip route add default via 10.76.2.209 dev eth0 2>/dev/null || true

cat > /etc/resolv.conf << 'EOF'
nameserver 192.168.122.1
nameserver 8.8.8.8
EOF

apt update
apt install isc-dhcp-relay -y

# ===== ROUTING KE PELARGIR DAN DOWNSTREAM (via eth2) =====
ip route add 10.76.2.216/30 via 10.76.2.214 dev eth2 2>/dev/null || true  # A3 (Pelargir-AnduinBanks)
ip route add 10.76.2.0/25 via 10.76.2.214 dev eth2 2>/dev/null || true    # A4 (Gilgalad, Cirdan)
ip route add 10.76.2.220/30 via 10.76.2.214 dev eth2 2>/dev/null || true  # A5 (Pelargir-Palantir)

# ===== ROUTING KE MORIA BRANCH VIA OSGILIATH =====
ip route add 10.76.2.224/30 via 10.76.2.209 dev eth0 2>/dev/null || true  # A7 (Osgiliath-Moria)
ip route add 10.76.2.228/30 via 10.76.2.209 dev eth0 2>/dev/null || true  # A8 (Moria-IronHills)
ip route add 10.76.2.232/30 via 10.76.2.209 dev eth0 2>/dev/null || true  # A9 (Moria-Wilderland)
ip route add 10.76.2.128/26 via 10.76.2.209 dev eth0 2>/dev/null || true  # A10 (Durin)
ip route add 10.76.2.192/29 via 10.76.2.209 dev eth0 2>/dev/null || true  # A11 (Khamul)

# ===== ROUTING KE RIVENDELL BRANCH VIA OSGILIATH =====
ip route add 10.76.2.236/30 via 10.76.2.209 dev eth0 2>/dev/null || true  # A12 (Osgiliath-Rivendell)
ip route add 10.76.2.200/29 via 10.76.2.209 dev eth0 2>/dev/null || true  # A13 (Vilya, Narya, DNS)

cat > /etc/default/isc-dhcp-relay << 'EOF'
SERVERS="10.76.2.202"
INTERFACES="eth0 eth1 eth2"
OPTIONS=""
EOF

service isc-dhcp-relay restart