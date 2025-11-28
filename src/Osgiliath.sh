#!/bin/bash

cat > /etc/network/interfaces << 'EOF'
auto eth0
iface eth0 inet dhcp

auto eth1
iface eth1 inet static
    address 10.76.2.205
    netmask 255.255.255.252

auto eth2
iface eth2 inet static
    address 10.76.2.221
    netmask 255.255.255.252

auto eth3
iface eth3 inet static
    address 10.76.2.233
    netmask 255.255.255.252
EOF

service networking restart

echo 'nameserver 192.168.122.1' > /etc/resolv.conf

sysctl -w net.ipv4.ip_forward=1

apt update
apt install iptables -y

route add -net 10.76.2.208 netmask 255.255.255.252 gw 10.76.2.206
route add -net 10.76.2.212 netmask 255.255.255.252 gw 10.76.2.206
route add -net 10.76.2.0 netmask 255.255.255.128 gw 10.76.2.206
route add -net 10.76.2.216 netmask 255.255.255.252 gw 10.76.2.206
route add -net 10.76.1.0 netmask 255.255.255.0 gw 10.76.2.206

route add -net 10.76.2.224 netmask 255.255.255.252 gw 10.76.2.222
route add -net 10.76.2.228 netmask 255.255.255.252 gw 10.76.2.222
route add -net 10.76.2.128 netmask 255.255.255.192 gw 10.76.2.222
route add -net 10.76.2.192 netmask 255.255.255.248 gw 10.76.2.222

route add -net 10.76.2.200 netmask 255.255.255.248 gw 10.76.2.234

iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE -s 10.76.0.0/16
