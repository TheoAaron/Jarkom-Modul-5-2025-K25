#!/bin/bash

cat > /etc/network/interfaces << 'EOF'
auto eth0
iface eth0 inet static
    address 10.76.2.234
    netmask 255.255.255.252
    gateway 10.76.2.233
EOF

ifdown eth0 && ifup eth0

echo 'nameserver 192.168.122.1' > /etc/resolv.conf

apt update
apt install apache2 -y

cat > /var/www/html/index.html << 'EOF'
Welcome to IronHills
EOF

service apache2 start