# palantir
# Create PORT_SCAN chain
iptables -N PORT_SCAN 2>/dev/null || iptables -F PORT_SCAN

iptables -F INPUT

iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A INPUT -i lo -j ACCEPT

iptables -A INPUT -p tcp -m state --state NEW -m recent --set --name portscan
iptables -A INPUT -p tcp -m state --state NEW -m recent --update --seconds 20 --hitcount 15 --name portscan -j PORT_SCAN

iptables -A PORT_SCAN -m recent --set --name blocked_scanner
iptables -A PORT_SCAN -j LOG --log-prefix "PORT_SCAN_DETECTED: " --log-level 4
iptables -A PORT_SCAN -j DROP

iptables -A INPUT -m recent --rcheck --name blocked_scanner -j DROP

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
# Download package
apt update
apt install rsyslog -y
service rsyslog start

dmesg -c
nmap -p 1-100 10.76.2.222
dmesg | grep PORT_SCAN
# Expected: Log entries dengan IP Elendil

# Step 5: Reset untuk test ulang
# Di Palantir
iptables -F
# Jalankan ulang script di Step 2
