#!/bin/bash

cat > /etc/network/interfaces << 'EOF'
auto eth0
iface eth0 inet static
    address 10.76.2.230
    netmask 255.255.255.252
EOF

service networking restart

ip addr add 10.76.2.230/30 dev eth0 2>/dev/null || true
ip link set eth0 up

cat > /etc/resolv.conf << 'EOF'
nameserver 192.168.122.1
nameserver 8.8.8.8
EOF

# Route ke Wilderland branch
route add -net 10.76.2.232 netmask 255.255.255.252 gw 10.76.2.229  # A9 (Moria-Wilderland)
route add -net 10.76.2.128 netmask 255.255.255.192 gw 10.76.2.229  # A10 (Durin)
route add -net 10.76.2.192 netmask 255.255.255.248 gw 10.76.2.229  # A11 (Khamul)

# Route ke Minastir branch via Moria
route add -net 10.76.2.208 netmask 255.255.255.252 gw 10.76.2.229  # A1 (Osgiliath-Minastir)
route add -net 10.76.2.212 netmask 255.255.255.252 gw 10.76.2.229  # A2 (Minastir-Pelargir)
route add -net 10.76.2.216 netmask 255.255.255.252 gw 10.76.2.229  # A3 (Pelargir-AnduinBanks)
route add -net 10.76.2.0 netmask 255.255.255.128 gw 10.76.2.229    # A4 (Gilgalad, Cirdan)
route add -net 10.76.2.220 netmask 255.255.255.252 gw 10.76.2.229  # A5 (Pelargir-Palantir)
route add -net 10.76.1.0 netmask 255.255.255.0 gw 10.76.2.229      # A6 (Elendil, Isildur)

# Route ke Rivendell branch via Moria
route add -net 10.76.2.236 netmask 255.255.255.252 gw 10.76.2.229  # A12 (Osgiliath-Rivendell)
route add -net 10.76.2.200 netmask 255.255.255.248 gw 10.76.2.229  # A13 (Vilya, Narya, DNS)

# Route ke Osgiliath via Moria
route add -net 10.76.2.224 netmask 255.255.255.252 gw 10.76.2.229  # A7 (Osgiliath-Moria)

route add default gw 10.76.2.229

apt update
apt install apache2 -y

cat > /var/www/html/index.html << 'EOF'
Welcome to IronHills
EOF

service apache2 start