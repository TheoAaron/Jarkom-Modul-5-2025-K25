#vilya
iptables -F INPUT
iptables -F OUTPUT

# Allow established connections
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A OUTPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

# Allow loopback
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT

# BLOCK incoming PING
iptables -A INPUT -p icmp --icmp-type echo-request -j DROP

# ALLOW outgoing PING
iptables -A OUTPUT -p icmp --icmp-type echo-request -j ACCEPT

# Allow other traffic
iptables -A INPUT -j ACCEPT
iptables -A OUTPUT -j ACCEPT

iptables -L INPUT -v -n --line-numbers | grep icmp

# Step 4: Testing
# Test 1: Ping FROM Vilya (should SUCCESS)
ping 10.76.2.201 -c 3  # Ping gateway Rivendell
# Expected: ✅ Success! (received 3 packets)

# Test 2: Ping TO Vilya (should FAIL)
# Di Osgiliath
ping 10.76.2.202 -c 3  # Ping Vilya
# Expected: Request timeout atau Destination Host Unreachable