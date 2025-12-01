#palantir
# Clear existing rules
iptables -F INPUT

# Allow established connections
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

# Allow loopback
iptables -A INPUT -i lo -j ACCEPT

# Allow SSH
iptables -A INPUT -p tcp --dport 22 -j ACCEPT

# FAKSI ELF: Gilgalad & Cirdan (10.76.2.0/25) - 07:00 to 15:00
iptables -A INPUT -p tcp --dport 80 -s 10.76.2.0/25 -m time --timestart 07:00 --timestop 15:00 --kerneltz -j ACCEPT

# FAKSI MANUSIA: Elendil & Isildur (10.76.1.0/24) - 17:00 to 23:00
iptables -A INPUT -p tcp --dport 80 -s 10.76.1.0/24 -m time --timestart 17:00 --timestop 23:00 --kerneltz -j ACCEPT

# BLOCK all other HTTP access
iptables -A INPUT -p tcp --dport 80 -j DROP

# Step 3: Check current time
date +"%H:%M"

# Step 4: Testing
# Current time = 14:xx (dalam window Elf - should SUCCESS from Gilgalad)
# Dari Gilgalad
curl http://10.76.2.222
# Expected: "Welcome to Palantir"

# Current time = 14:xx (di luar window Manusia - should FAIL from Elendil)
# Dari Elendil
curl http://10.76.2.222 -m 5
# Expected: Connection timeout

# Simulate 19:00 untuk test Manusia:
# Di Palantir
date -s "2024-11-27 19:00:00"

# Test dari Elendil
curl http://10.76.2.222
# Expected: "Welcome to Palantir"