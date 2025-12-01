#!/bin/bash

cat > /etc/network/interfaces << 'IFACE'
auto eth0
iface eth0 inet dhcp
IFACE

# Restart networking dengan ip command
ip link set eth0 down
ip addr flush dev eth0
ip link set eth0 up

# Request DHCP lease
udhcpc -i eth0 -t 5 -q -f