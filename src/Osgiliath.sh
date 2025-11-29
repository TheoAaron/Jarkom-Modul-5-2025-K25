#!/bin/bash

# Enable IP forwarding first
echo 1 > /proc/sys/net/ipv4/ip_forward
sysctl -w net.ipv4.ip_forward=1

# Bring up interfaces
ip link set eth0 up
ip link set eth1 up
ip link set eth2 up
ip link set eth3 up

# Configure static IPs manually (DO NOT flush eth0 - it's DHCP from NAT)
ip addr flush dev eth1
ip addr flush dev eth2
ip addr flush dev eth3
ip addr add 10.76.2.209/30 dev eth1
ip addr add 10.76.2.225/30 dev eth2
ip addr add 10.76.2.237/30 dev eth3

echo 'nameserver 192.168.122.1' > /etc/resolv.conf

apt update
apt install iptables -y

# Add routes for directly connected subnets first
ip route add 10.76.2.208/30 dev eth1 2>/dev/null || true
ip route add 10.76.2.224/30 dev eth2 2>/dev/null || true
ip route add 10.76.2.236/30 dev eth3 2>/dev/null || true

# ===== ROUTING KE CABANG MINASTIR (eth1) =====
route add -net 10.76.2.212 netmask 255.255.255.252 gw 10.76.2.210  # A2 (Minastir-Pelargir)
route add -net 10.76.2.216 netmask 255.255.255.252 gw 10.76.2.210  # A3 (Pelargir-AnduinBanks)
route add -net 10.76.2.0 netmask 255.255.255.128 gw 10.76.2.210    # A4 (Gilgalad, Cirdan)
route add -net 10.76.2.220 netmask 255.255.255.252 gw 10.76.2.210  # A5 (Pelargir-Palantir)
route add -net 10.76.1.0 netmask 255.255.255.0 gw 10.76.2.210      # A6 (Elendil, Isildur)

# ===== ROUTING KE CABANG MORIA (eth2) =====
route add -net 10.76.2.228 netmask 255.255.255.252 gw 10.76.2.226  # A8 (Moria-IronHills)
route add -net 10.76.2.232 netmask 255.255.255.252 gw 10.76.2.226  # A9 (Moria-Wilderland)
route add -net 10.76.2.128 netmask 255.255.255.192 gw 10.76.2.226  # A10 (Durin)
route add -net 10.76.2.192 netmask 255.255.255.248 gw 10.76.2.226  # A11 (Khamul)

# ===== ROUTING KE CABANG RIVENDELL (eth3) =====
route add -net 10.76.2.200 netmask 255.255.255.248 gw 10.76.2.238  # A13 (Vilya, Narya)

# ===== NAT MENGGUNAKAN SNAT (BUKAN MASQUERADE) =====
ETH0_IP=$(ip -4 addr show eth0 | grep -oP '(?<=inet\s)\d+(\.\d+){3}')
iptables -t nat -A POSTROUTING -s 10.76.0.0/16 -o eth0 -j SNAT --to-source $ETH0_IP