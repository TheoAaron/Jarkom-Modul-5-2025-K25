#!/bin/bash

cat > /etc/network/interfaces << 'EOF'
auto eth0
iface eth0 inet static
    address 10.76.2.230
    netmask 255.255.255.252
EOF

service networking restart

# Ensure IP address is assigned
ip addr add 10.76.2.230/30 dev eth0 2>/dev/null || true
ip link set eth0 up

echo 'nameserver 192.168.122.1' > /etc/resolv.conf

route add default gw 10.76.2.229  # Default ke Moria

apt update
apt install apache2 -y

cat > /var/www/html/index.html << 'EOF'
Welcome to IronHills
EOF

service apache2 start