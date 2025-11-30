#!/bin/bash

#!/bin/bash

cat > /etc/network/interfaces << 'EOF'
auto eth0
iface eth0 inet static
    address 10.76.2.234
    netmask 255.255.255.252

auto eth1
iface eth1 inet static
    address 10.76.2.129
    netmask 255.255.255.192

auto eth2
iface eth2 inet static
    address 10.76.2.193
    netmask 255.255.255.248
EOF

service networking restart

ip addr add 10.76.2.234/30 dev eth0 2>/dev/null || true
ip addr add 10.76.2.129/26 dev eth1 2>/dev/null || true
ip addr add 10.76.2.193/29 dev eth2 2>/dev/null || true
ip link set eth0 up
ip link set eth1 up
ip link set eth2 up

echo 1 > /proc/sys/net/ipv4/ip_forward
sysctl -w net.ipv4.ip_forward=1

cat > /etc/resolv.conf << 'EOF'
nameserver 192.168.122.1
nameserver 8.8.8.8
EOF

route add default gw 10.76.2.233

apt update
apt install isc-dhcp-relay -y

cat > /etc/default/isc-dhcp-relay << 'EOF'
SERVERS="10.76.2.202"
INTERFACES="eth0 eth1 eth2"
OPTIONS=""
EOF

service isc-dhcp-relay restart