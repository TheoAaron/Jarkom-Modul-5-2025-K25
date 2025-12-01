#!/bin/bash

# Bring up interfaces
ip link set eth0 up
ip link set eth1 up
ip link set eth2 up
ip link set eth3 up

# Apply static IPs untuk internal interfaces
ip addr add 10.76.2.237/30 dev eth1 2>/dev/null || true  # ke Rivendell
ip addr add 10.76.2.225/30 dev eth2 2>/dev/null || true  # ke Moria
ip addr add 10.76.2.209/30 dev eth3 2>/dev/null || true  # ke Minastir

# Start DHCP untuk eth0
udhcpc -i eth0 -n -q 2>/dev/null &
sleep 5

# Check eth0 IP
ETH0_IP=$(ip -4 addr show eth0 | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | head -1)

if [ -z "$ETH0_IP" ]; then
    echo "Warning: DHCP failed, using static IP"
    ip addr add 192.168.122.100/24 dev eth0 2>/dev/null || true
    ETH0_IP="192.168.122.100"
fi

# Ensure default route exists
ip route del default 2>/dev/null
ip route add default via 192.168.122.1 dev eth0 2>/dev/null || true

echo "eth0 IP: $ETH0_IP"
echo "Internal interfaces:"
ip -4 addr show eth1 | grep inet
ip -4 addr show eth2 | grep inet
ip -4 addr show eth3 | grep inet

# Test koneksi
echo "Testing internet connectivity..."
ping -c 1 8.8.8.8 > /dev/null 2>&1 && echo "✓ Internet OK" || echo "✗ Internet FAILED"

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
# To Minastir branch (via eth3)
route add -net 10.76.2.212 netmask 255.255.255.252 gw 10.76.2.210 2>/dev/null
route add -net 10.76.2.216 netmask 255.255.255.252 gw 10.76.2.210 2>/dev/null
route add -net 10.76.2.0 netmask 255.255.255.128 gw 10.76.2.210 2>/dev/null
route add -net 10.76.2.220 netmask 255.255.255.252 gw 10.76.2.210 2>/dev/null
route add -net 10.76.1.0 netmask 255.255.255.0 gw 10.76.2.210 2>/dev/null

# To Moria branch (via eth2)
route add -net 10.76.2.228 netmask 255.255.255.252 gw 10.76.2.226 2>/dev/null
route add -net 10.76.2.232 netmask 255.255.255.252 gw 10.76.2.226 2>/dev/null
route add -net 10.76.2.128 netmask 255.255.255.192 gw 10.76.2.226 2>/dev/null
route add -net 10.76.2.192 netmask 255.255.255.248 gw 10.76.2.226 2>/dev/null

# To Rivendell branch (via eth1)
route add -net 10.76.2.200 netmask 255.255.255.248 gw 10.76.2.238 2>/dev/null