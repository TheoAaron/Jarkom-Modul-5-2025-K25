#!/bin/bash

cat > /etc/network/interfaces << 'EOF'
auto eth0
iface eth0 inet static
    address 10.76.2.218
    netmask 255.255.255.252

auto eth1
iface eth1 inet static
    address 10.76.2.1
    netmask 255.255.255.128
EOF

service networking restart

# Ensure IP addresses are assigned
ip addr add 10.76.2.218/30 dev eth0 2>/dev/null || true
ip addr add 10.76.2.1/25 dev eth1 2>/dev/null || true
ip link set eth0 up
ip link set eth1 up

echo 'nameserver 192.168.122.1' > /etc/resolv.conf

sysctl -w net.ipv4.ip_forward=1

apt update
apt install isc-dhcp-relay -y

route add default gw 10.76.2.217  # Default ke Pelargir

cat > /etc/default/isc-dhcp-relay << 'EOF'
SERVERS="10.76.2.202"
INTERFACES="eth0 eth1"
OPTIONS=""
EOF

service isc-dhcp-relay restart