#IronHils

iptables -F INPUT

iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A INPUT -i lo -j ACCEPT
iptables -A INPUT -p tcp --dport 22 -j ACCEPT

iptables -A INPUT -p tcp --dport 80 -s 10.76.2.128/26 -m time --weekdays Sat,Sun --kerneltz -j ACCEPT
iptables -A INPUT -p tcp --dport 80 -s 10.76.2.192/29 -m time --weekdays Sat,Sun --kerneltz -j ACCEPT
iptables -A INPUT -p tcp --dport 80 -s 10.76.1.0/24 -m time --weekdays Sat,Sun --kerneltz -j ACCEPT

iptables -A INPUT -p tcp --dport 80 -j DROP

# Step 3: Check current day
date +"%A, %Y-%m-%d"

# Step 4: Testing
# Test pada WEEKDAY (sekarang = Rabu - should FAIL)
# Dari Durin/Khamul/Elendil/Isildur
curl http://10.76.2.230 -m 5

# Expected: Connection timeout atau connection refused
# Simulate SATURDAY untuk testing:
# Di IronHills - Change system date
date -s "Sat Nov 30 10:00:00 2024"
date

# Sekarang test dari client
curl http://10.76.2.230
# Expected: "Welcome to IronHills"