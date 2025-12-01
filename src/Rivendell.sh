#!/bin/bash

# Restart interfaces menggunakan /etc/network/interfaces
ip link set eth0 down
ip link set eth1 down

ip addr flush dev eth0 2>/dev/null
ip addr flush dev eth1 2>/dev/null

ip link set eth0 up
ip link set eth1 up

# Apply IP dari /etc/network/interfaces
ip addr add 10.76.2.238/30 dev eth0 2>/dev/null || true
ip addr add 10.76.2.201/29 dev eth1 2>/dev/null || true

echo 1 > /proc/sys/net/ipv4/ip_forward
sysctl -w net.ipv4.ip_forward=1

cat > /etc/resolv.conf << 'EOF'
nameserver 192.168.122.1
nameserver 8.8.8.8
EOF

echo "Verifying interfaces:"
ip -4 addr show eth0 | grep inet
ip -4 addr show eth1 | grep inet

# Add default route
ip route del default 2>/dev/null
ip route add default via 10.76.2.237 dev eth0 2>/dev/null || true

echo "Route table:"
ip route show

echo "Testing gateway..."
ping -c 2 10.76.2.237 > /dev/null 2>&1 && echo "✓ Gateway reachable" || echo "✗ Gateway unreachable"

apt update
apt install isc-dhcp-relay -y

cat > /etc/default/isc-dhcp-relay << 'EOF'
SERVERS="10.76.2.202"
INTERFACES="eth0 eth1"
OPTIONS=""
EOF

service isc-dhcp-relay restart