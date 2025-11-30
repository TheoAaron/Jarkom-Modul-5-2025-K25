#!/bin/bash

# 1. Setup eth0 (NAT interface)
ip link set eth0 up

# Try DHCP first
dhclient -v eth0
sleep 3

# Check if got IP
ETH0_IP=$(ip -4 addr show eth0 | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | head -1)

if [ -z "$ETH0_IP" ]; then
    echo "DHCP failed, setting manual IP..."
    ip addr add 192.168.122.100/24 dev eth0
    ip route add default via 192.168.122.1 dev eth0
    ETH0_IP="192.168.122.100"
fi

echo "eth0 IP: $ETH0_IP"

# 2. Setup internal interfaces
ip link set eth1 up
ip link set eth2 up
ip link set eth3 up

ip addr flush dev eth1
ip addr flush dev eth2
ip addr flush dev eth3

ip addr add 10.76.2.209/30 dev eth1
ip addr add 10.76.2.225/30 dev eth2
ip addr add 10.76.2.237/30 dev eth3

# 3. Enable IP forwarding
echo 1 > /proc/sys/net/ipv4/ip_forward
sysctl -w net.ipv4.ip_forward=1

# 4. Set DNS
cat > /etc/resolv.conf << 'EOF'
nameserver 192.168.122.1
nameserver 8.8.8.8
EOF

# 5. Setup iptables NAT
iptables -F
iptables -t nat -F
iptables -X

iptables -P INPUT ACCEPT
iptables -P FORWARD ACCEPT
iptables -P OUTPUT ACCEPT

iptables -t nat -A POSTROUTING -s 10.76.0.0/16 -o eth0 -j SNAT --to-source $ETH0_IP
iptables -A FORWARD -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A FORWARD -s 10.76.0.0/16 -j ACCEPT

# 6. Setup routing
# To Minastir branch
route add -net 10.76.2.212 netmask 255.255.255.252 gw 10.76.2.210 2>/dev/null
route add -net 10.76.2.216 netmask 255.255.255.252 gw 10.76.2.210 2>/dev/null
route add -net 10.76.2.0 netmask 255.255.255.128 gw 10.76.2.210 2>/dev/null
route add -net 10.76.2.220 netmask 255.255.255.252 gw 10.76.2.210 2>/dev/null
route add -net 10.76.1.0 netmask 255.255.255.0 gw 10.76.2.210 2>/dev/null

# To Moria branch
route add -net 10.76.2.228 netmask 255.255.255.252 gw 10.76.2.226 2>/dev/null
route add -net 10.76.2.232 netmask 255.255.255.252 gw 10.76.2.226 2>/dev/null
route add -net 10.76.2.128 netmask 255.255.255.192 gw 10.76.2.226 2>/dev/null
route add -net 10.76.2.192 netmask 255.255.255.248 gw 10.76.2.226 2>/dev/null

# To Rivendell branch
route add -net 10.76.2.200 netmask 255.255.255.248 gw 10.76.2.238 2>/dev/null