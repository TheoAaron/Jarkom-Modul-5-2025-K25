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

route add default gw 10.76.2.229

apt update
apt install apache2 -y

cat > /var/www/html/index.html << 'EOF'
Welcome to IronHills
EOF

service apache2 start