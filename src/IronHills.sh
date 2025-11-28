#!/bin/bash

cat > /etc/network/interfaces << 'EOF'
auto eth0
iface eth0 inet static
address 10.76.2.226
netmask 255.255.255.252
gateway 10.76.2.225
EOF

service networking restart

apt update
apt install apache2 -y

cat > /var/www/html/index.html << 'EOF'
Welcome to IronHills
EOF

service apache2 start
