#!/bin/bash

cat > /etc/network/interfaces << 'EOF'
auto eth0
iface eth0 inet static
    address 10.76.2.203
    netmask 255.255.255.248
EOF

service networking restart

# Ensure IP address is assigned
ip addr add 10.76.2.203/29 dev eth0 2>/dev/null || true
ip link set eth0 up

cat > /etc/resolv.conf << 'EOF'
nameserver 127.0.0.1
nameserver 192.168.122.1
EOF

route add default gw 10.76.2.201  # Default ke Rivendell

apt update
apt install bind9 -y

cat > /etc/bind/named.conf.options << 'EOF'
options {
    directory "/var/cache/bind";
    forwarders {
        192.168.122.1;
    };
    allow-query { any; };
    auth-nxdomain no;
    listen-on-v6 { any; };
};
EOF

service bind9 restart