#vilya
# Clear existing NAT rules
iptables -t nat -F OUTPUT

# REDIRECT: Khamul subnet (10.76.2.192/29) → IronHills (10.76.2.230)
iptables -t nat -A OUTPUT -d 10.76.2.192/29 -j DNAT --to-destination 10.76.2.230

# Verify rules
iptables -t nat -L OUTPUT -v -n

# Terminal 1 - Di IronHills
tcpdump -i eth0 -n 'host 10.76.2.202 and port 80'
# Send traffic dari Vilya:
# Terminal 2 - Di Vilya
# Coba akses Khamul IP, akan redirect ke IronHills
curl http://10.76.2.194

# Expected di IronHills tcpdump:
# ... 10.76.2.202.xxxxx > 10.76.2.230.80: ... (SYN)
# Dan curl response:
# Welcome to IronHills