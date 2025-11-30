#IronHils

iptables -F INPUT

# Allow established connections
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

# Allow loopback
iptables -A INPUT -i lo -j ACCEPT

# Allow SSH (untuk management)
iptables -A INPUT -p tcp --dport 22 -j ACCEPT

# WEEKEND ACCESS ONLY (Sat & Sun)
# Faksi Kurcaci & Pengkhianat: Durin (10.76.2.128/26) & Khamul (10.76.2.192/29)
iptables -A INPUT -p tcp --dport 80 -s 10.76.2.128/26 -m time --weekdays Sat,Sun -j ACCEPT
iptables -A INPUT -p tcp --dport 80 -s 10.76.2.192/29 -m time --weekdays Sat,Sun -j ACCEPT

# Faksi Manusia: Elendil & Isildur (10.76.1.0/24)
iptables -A INPUT -p tcp --dport 80 -s 10.76.1.0/24 -m time --weekdays Sat,Sun -j ACCEPT

# BLOCK all other HTTP access
iptables -A INPUT -p tcp --dport 80 -j DROP

# Step 3: Check current day
bashdate +"%A, %Y-%m-%d"

# Step 4: Testing
# Test pada WEEKDAY (sekarang = Rabu - should FAIL)
# Dari Durin/Khamul/Elendil/Isildur
curl http://10.76.2.230 -m 5

# Expected: Connection timeout atau connection refused
# Simulate SATURDAY untuk testing:
# Di IronHills - Change system date
date -s 'Sat Nov 30 10:00:00 WIB 2024'

# Sekarang test dari client
curl http://10.76.2.230
# Expected: "Welcome to IronHills"

# Restore date after testing:
# Di IronHills
date -s 'Wed Nov 27 14:00:00 WIB 2024'