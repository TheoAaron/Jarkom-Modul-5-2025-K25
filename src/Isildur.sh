#!/bin/bash

cat > /etc/network/interfaces << 'EOF'
auto eth0
iface eth0 inet dhcp
EOF

service networking restart

echo 'nameserver 192.168.122.1' > /etc/resolv.conf
