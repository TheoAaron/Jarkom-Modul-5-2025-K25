#!/bin/bash

ip link set eth0 up
ip link set eth1 up
ip link set eth2 up

# Assign IP addresses
ip addr flush dev eth0 2>/dev/null
ip addr flush dev eth1 2>/dev/null
ip addr flush dev eth2 2>/dev/null
ip addr add 10.76.2.226/30 dev eth0
ip addr add 10.76.2.229/30 dev eth1
ip addr add 10.76.2.233/30 dev eth2

echo 1 > /proc/sys/net/ipv4/ip_forward
sysctl -w net.ipv4.ip_forward=1

cat > /etc/resolv.conf << 'EOF'
nameserver 192.168.122.1
nameserver 8.8.8.8
EOF

# Route ke Wilderland branch
route add -net 10.76.2.128 netmask 255.255.255.192 gw 10.76.2.234  # A10 (Durin)
route add -net 10.76.2.192 netmask 255.255.255.248 gw 10.76.2.234  # A11 (Khamul)

# Route ke Minastir branch via Osgiliath
route add -net 10.76.2.208 netmask 255.255.255.252 gw 10.76.2.225  # A1 (Osgiliath-Minastir)
route add -net 10.76.2.212 netmask 255.255.255.252 gw 10.76.2.225  # A2 (Minastir-Pelargir)
route add -net 10.76.2.216 netmask 255.255.255.252 gw 10.76.2.225  # A3 (Pelargir-AnduinBanks)
route add -net 10.76.2.0 netmask 255.255.255.128 gw 10.76.2.225    # A4 (Gilgalad, Cirdan)
route add -net 10.76.2.220 netmask 255.255.255.252 gw 10.76.2.225  # A5 (Pelargir-Palantir)
route add -net 10.76.1.0 netmask 255.255.255.0 gw 10.76.2.225      # A6 (Elendil, Isildur)

# Route ke Rivendell branch via Osgiliath
route add -net 10.76.2.236 netmask 255.255.255.252 gw 10.76.2.225  # A12 (Osgiliath-Rivendell)
route add -net 10.76.2.200 netmask 255.255.255.248 gw 10.76.2.225  # A13 (Vilya, Narya, DNS)

route add default gw 10.76.2.225

apt update
apt install isc-dhcp-relay -y

cat > /etc/default/isc-dhcp-relay << 'EOF'
SERVERS="10.76.2.202"
INTERFACES="eth0 eth1 eth2"
OPTIONS=""
EOF

service isc-dhcp-relay restart