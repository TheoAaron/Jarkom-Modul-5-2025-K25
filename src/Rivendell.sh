#!/bin/bash

# Enable IP forwarding first
echo 1 > /proc/sys/net/ipv4/ip_forward
sysctl -w net.ipv4.ip_forward=1

# Bring up interfaces
ip link set eth0 up
ip link set eth1 up

# Flush and configure IPs manually
ip addr flush dev eth0
ip addr flush dev eth1
ip addr add 10.76.2.238/30 dev eth0
ip addr add 10.76.2.201/29 dev eth1

echo 'nameserver 192.168.122.1' > /etc/resolv.conf

apt update
apt install isc-dhcp-relay -y

# Add route for directly connected subnet
ip route add 10.76.2.236/30 dev eth0 2>/dev/null || true
ip route add 10.76.2.200/29 dev eth1 2>/dev/null || true

route add default gw 10.76.2.237  # Default ke Osgiliath

cat > /etc/default/isc-dhcp-relay << 'EOF'
SERVERS="10.76.2.202"
INTERFACES="eth0 eth1"
OPTIONS=""
EOF

service isc-dhcp-relay restart