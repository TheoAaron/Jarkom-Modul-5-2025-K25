#!/bin/bash

cat > /etc/network/interfaces << 'EOF'
auto eth0
iface eth0 inet static
    address 10.76.2.203
    netmask 255.255.255.248
    gateway 10.76.2.201
EOF

ifdown eth0 && ifup eth0

echo 'nameserver 192.168.122.1' > /etc/resolv.conf

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