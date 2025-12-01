# narya
# Clear existing rules
iptables -F INPUT

# Allow established connections
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

# Allow loopback
iptables -A INPUT -i lo -j ACCEPT

# ALLOW DNS from Vilya ONLY (10.76.2.202)
iptables -A INPUT -p tcp --dport 53 -s 10.76.2.202 -j ACCEPT
iptables -A INPUT -p udp --dport 53 -s 10.76.2.202 -j ACCEPT

# BLOCK DNS from everyone else
iptables -A INPUT -p tcp --dport 53 -j DROP
iptables -A INPUT -p udp --dport 53 -j DROP

# Allow other traffic
iptables -A INPUT -j ACCEPT

#Test
apt-get update
apt-get install netcat-traditional

# Test From Osgiliath (should FAIL)
# Di Osgiliath  
nc -zvu 10.76.2.203 53 -w 3
# Expected: Timeout atau connection refused