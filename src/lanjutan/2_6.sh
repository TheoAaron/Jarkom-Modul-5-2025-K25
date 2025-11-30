# palantir
# Create PORT_SCAN chain
iptables -N PORT_SCAN 2>/dev/null || iptables -F PORT_SCAN

# Clear existing rules
iptables -F INPUT

# Allow established connections
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

# Allow loopback
iptables -A INPUT -i lo -j ACCEPT

# Track NEW connections for port scan detection
iptables -A INPUT -p tcp -m state --state NEW -m recent --set --name portscan

# If > 15 connections in 20 seconds, jump to PORT_SCAN chain
iptables -A INPUT -p tcp -m state --state NEW -m recent --update --seconds 20 --hitcount 15 --name portscan -j PORT_SCAN

# PORT_SCAN chain actions
iptables -A PORT_SCAN -m recent --set --name blocked_scanner
iptables -A PORT_SCAN -j LOG --log-prefix "PORT_SCAN_DETECTED: " --log-level 4
iptables -A PORT_SCAN -j DROP

# Block ALL traffic from known scanners
iptables -A INPUT -m recent --rcheck --name blocked_scanner -j DROP

# Allow normal traffic
iptables -A INPUT -p tcp --dport 80 -j ACCEPT
iptables -A INPUT -p tcp --dport 22 -j ACCEPT

# Test 1: Normal access (should work)
# Dari Elendil
curl http://10.76.2.222
# Expected: "Welcome to Palantir"

# Test 2: Port scan (should be blocked after 15 ports)
# Dari Elendil - Install nmap jika belum ada
# apt update && apt install nmap -y
nmap -p 1-100 10.76.2.222
# Expected: Scan akan timeout/hang setelah ~15 ports

# Test 3: After blocked, try ping/curl (should fail)
# Dari Elendil (yang tadi nmap)
ping 10.76.2.222 -c 3
curl http://10.76.2.222
# Expected: Semua blocked!

# Step 4: Check logs
# Di Palantir
dmesg | grep PORT_SCAN_DETECTED
# Expected: Log entries dengan IP Elendil

# Step 5: Reset untuk test ulang
# Di Palantir
iptables -F
# Jalankan ulang script di Step 2