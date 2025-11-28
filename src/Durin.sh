#!/bin/bash

cat > /etc/network/interfaces << 'IFACE'
auto eth0
iface eth0 inet dhcp
IFACE

ifdown eth0 && ifup eth0

echo 'nameserver 192.168.122.1' > /etc/resolv.conf