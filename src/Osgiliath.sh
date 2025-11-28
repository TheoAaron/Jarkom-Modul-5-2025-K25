#!/bin/bash

cat > /etc/network/interfaces << 'EOF'
auto eth0
iface eth0 inet dhcp

auto eth1
iface eth1 inet static
    address 10.76.2.209
    netmask 255.255.255.252

auto eth2
iface eth2 inet static
    address 10.76.2.225
    netmask 255.255.255.252

auto eth3
iface eth3 inet static
    address 10.76.2.237
    netmask 255.255.255.252
EOF

ifdown eth0 && ifup eth0
ifdown eth1 && ifup eth1
ifdown eth2 && ifup eth2
ifdown eth3 && ifup eth3

echo 'nameserver 192.168.122.1' > /etc/resolv.conf

sysctl -w net.ipv4.ip_forward=1

apt update
apt install iptables -y

# ===== ROUTING KE CABANG MINASTIR (eth1) =====
route add -net 10.76.2.212 netmask 255.255.255.252 gw 10.76.2.210  # A2 (Minastir-Pelargir)
route add -net 10.76.2.216 netmask 255.255.255.252 gw 10.76.2.210  # A3 (Pelargir-AnduinBanks)
route add -net 10.76.2.0 netmask 255.255.255.128 gw 10.76.2.210    # A4 (Gilgalad, Cirdan)
route add -net 10.76.2.220 netmask 255.255.255.252 gw 10.76.2.210  # A5 (Pelargir-Palantir)
route add -net 10.76.1.0 netmask 255.255.255.0 gw 10.76.2.210      # A6 (Elendil, Isildur)

# ===== ROUTING KE CABANG MORIA (eth2) =====
route add -net 10.76.2.232 netmask 255.255.255.252 gw 10.76.2.226  # A8 (Moria-IronHills)
route add -net 10.76.2.229 netmask 255.255.255.252 gw 10.76.2.226  # A9 (Moria-Wilderland)
route add -net 10.76.2.128 netmask 255.255.255.192 gw 10.76.2.226  # A10 (Durin)
route add -net 10.76.2.192 netmask 255.255.255.248 gw 10.76.2.226  # A11 (Khamul)

# ===== ROUTING KE CABANG RIVENDELL (eth3) =====
route add -net 10.76.2.200 netmask 255.255.255.248 gw 10.76.2.238  # A13 (Vilya, Narya)

# ===== NAT MENGGUNAKAN SNAT (BUKAN MASQUERADE) =====
ETH0_IP=$(ip -4 addr show eth0 | grep -oP '(?<=inet\s)\d+(\.\d+){3}')
iptables -t nat -A POSTROUTING -s 10.76.0.0/16 -o eth0 -j SNAT --to-source $ETH0_IP