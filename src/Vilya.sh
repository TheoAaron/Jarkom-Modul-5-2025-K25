#!/bin/bash

cat > /etc/network/interfaces << 'EOF'
auto eth0
iface eth0 inet static
    address 10.76.2.202
    netmask 255.255.255.248
    gateway 10.76.2.201
EOF

ifdown eth0 && ifup eth0

echo 'nameserver 192.168.122.1' > /etc/resolv.conf

apt update
apt install isc-dhcp-server -y

echo 'INTERFACESv4="eth0"' > /etc/default/isc-dhcp-server

cat > /etc/dhcp/dhcpd.conf << 'EOF'
# Subnet A4: Gilgalad & Cirdan (120 host)
subnet 10.76.2.0 netmask 255.255.255.128 {
    range 10.76.2.2 10.76.2.126;
    option routers 10.76.2.1;
    option broadcast-address 10.76.2.127;
    option domain-name-servers 10.76.2.203;
    default-lease-time 600;
    max-lease-time 7200;
}

# Subnet A6: Elendil & Isildur (230 host)
subnet 10.76.1.0 netmask 255.255.255.0 {
    range 10.76.1.2 10.76.1.254;
    option routers 10.76.1.1;
    option broadcast-address 10.76.1.255;
    option domain-name-servers 10.76.2.203;
    default-lease-time 600;
    max-lease-time 7200;
}

# Subnet A10: Durin (51 host)
subnet 10.76.2.128 netmask 255.255.255.192 {
    range 10.76.2.130 10.76.2.190;
    option routers 10.76.2.129;
    option broadcast-address 10.76.2.191;
    option domain-name-servers 10.76.2.203;
    default-lease-time 600;
    max-lease-time 7200;
}

# Subnet A11: Khamul (5 host)
subnet 10.76.2.192 netmask 255.255.255.248 {
    range 10.76.2.194 10.76.2.198;
    option routers 10.76.2.193;
    option broadcast-address 10.76.2.199;
    option domain-name-servers 10.76.2.203;
    default-lease-time 600;
    max-lease-time 7200;
}

# Subnet A13: Vilya & Narya (tidak perlu range karena static)
subnet 10.76.2.200 netmask 255.255.255.248 {
}
EOF

service isc-dhcp-server restart