#!/bin/bash

# Enable IP forwarding first
echo 1 > /proc/sys/net/ipv4/ip_forward
sysctl -w net.ipv4.ip_forward=1

# Bring up interfaces
ip link set eth0 up
ip link set eth1 up

# Flush and assign IP addresses
ip addr flush dev eth0 2>/dev/null
ip addr flush dev eth1 2>/dev/null
ip addr add 10.76.2.218/30 dev eth0  # ke Pelargir
ip addr add 10.76.2.1/25 dev eth1    # ke Switch5 (Gilgalad, Cirdan)

# Set default route FIRST
ip route add default via 10.76.2.217 dev eth0 2>/dev/null || true

cat > /etc/resolv.conf << 'EOF'
nameserver 192.168.122.1
nameserver 8.8.8.8
EOF

apt update
apt install isc-dhcp-relay -y

# Route ke semua subnet via Pelargir
ip route add 10.76.2.212/30 via 10.76.2.217 dev eth0 2>/dev/null || true  # A2 (Minastir-Pelargir)
ip route add 10.76.2.220/30 via 10.76.2.217 dev eth0 2>/dev/null || true  # A5 (Pelargir-Palantir)
ip route add 10.76.1.0/24 via 10.76.2.217 dev eth0 2>/dev/null || true    # A6 (Elendil, Isildur)
ip route add 10.76.2.208/30 via 10.76.2.217 dev eth0 2>/dev/null || true  # A1 (Osgiliath-Minastir)
ip route add 10.76.2.224/30 via 10.76.2.217 dev eth0 2>/dev/null || true  # A7 (Osgiliath-Moria)
ip route add 10.76.2.228/30 via 10.76.2.217 dev eth0 2>/dev/null || true  # A8 (Moria-IronHills)
ip route add 10.76.2.232/30 via 10.76.2.217 dev eth0 2>/dev/null || true  # A9 (Moria-Wilderland)
ip route add 10.76.2.128/26 via 10.76.2.217 dev eth0 2>/dev/null || true  # A10 (Durin)
ip route add 10.76.2.192/29 via 10.76.2.217 dev eth0 2>/dev/null || true  # A11 (Khamul)
ip route add 10.76.2.236/30 via 10.76.2.217 dev eth0 2>/dev/null || true  # A12 (Osgiliath-Rivendell)
ip route add 10.76.2.200/29 via 10.76.2.217 dev eth0 2>/dev/null || true  # A13 (Vilya, Narya, DNS)

cat > /etc/default/isc-dhcp-relay << 'EOF'
SERVERS="10.76.2.202"
INTERFACES="eth0 eth1"
OPTIONS=""
EOF

service isc-dhcp-relay restart