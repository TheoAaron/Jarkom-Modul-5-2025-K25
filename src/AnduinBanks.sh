#!/bin/bash

ip link set eth0 up
ip link set eth1 up

# Assign IP addresses
ip addr flush dev eth0 2>/dev/null
ip addr flush dev eth1 2>/dev/null
ip addr add 10.76.2.218/30 dev eth0
ip addr add 10.76.2.1/25 dev eth1

echo 1 > /proc/sys/net/ipv4/ip_forward
sysctl -w net.ipv4.ip_forward=1

cat > /etc/resolv.conf << 'EOF'
nameserver 192.168.122.1
nameserver 8.8.8.8
EOF

apt update
apt install isc-dhcp-relay -y

# Route ke semua subnet via Pelargir
route add -net 10.76.2.212 netmask 255.255.255.252 gw 10.76.2.217  # A2 (Minastir-Pelargir)
route add -net 10.76.2.220 netmask 255.255.255.252 gw 10.76.2.217  # A5 (Pelargir-Palantir)
route add -net 10.76.1.0 netmask 255.255.255.0 gw 10.76.2.217      # A6 (Elendil, Isildur)
route add -net 10.76.2.208 netmask 255.255.255.252 gw 10.76.2.217  # A1 (Osgiliath-Minastir)
route add -net 10.76.2.224 netmask 255.255.255.252 gw 10.76.2.217  # A7 (Osgiliath-Moria)
route add -net 10.76.2.228 netmask 255.255.255.252 gw 10.76.2.217  # A8 (Moria-IronHills)
route add -net 10.76.2.232 netmask 255.255.255.252 gw 10.76.2.217  # A9 (Moria-Wilderland)
route add -net 10.76.2.128 netmask 255.255.255.192 gw 10.76.2.217  # A10 (Durin)
route add -net 10.76.2.192 netmask 255.255.255.248 gw 10.76.2.217  # A11 (Khamul)
route add -net 10.76.2.236 netmask 255.255.255.252 gw 10.76.2.217  # A12 (Osgiliath-Rivendell)
route add -net 10.76.2.200 netmask 255.255.255.248 gw 10.76.2.217  # A13 (Vilya, Narya, DNS)

route add default gw 10.76.2.217  # Default ke Pelargir

cat > /etc/default/isc-dhcp-relay << 'EOF'
SERVERS="10.76.2.202"
INTERFACES="eth0 eth1"
OPTIONS=""
EOF

service isc-dhcp-relay restart