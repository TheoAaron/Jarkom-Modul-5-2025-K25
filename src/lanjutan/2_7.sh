#ironhils

iptables -F INPUT

# Allow established connections
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

# Allow loopback
iptables -A INPUT -i lo -j ACCEPT

# Allow SSH
iptables -A INPUT -p tcp --dport 22 -j ACCEPT

# LIMIT: Max 3 concurrent connections per IP
iptables -A INPUT -p tcp --dport 80 -m connlimit --connlimit-above 3 --connlimit-mask 32 -j REJECT --reject-with tcp-reset

# Allow HTTP (up to limit)
iptables -A INPUT -p tcp --dport 80 -j ACCEPT

# Step 3: Testing
# Test 1: Open 3 connections (should work)
# Dari Durin/Elendil
for i in {1..3}; do
  curl http://10.76.2.230 &
done
wait
# Expected: All 3 succeed
# Test 2: Open 5 connections simultaneously

# Dari Durin/Elendil
for i in {1..5}; do
  (curl http://10.76.2.230 && echo "Connection $i: OK") &
done
wait
Expected:
# First 3: OK
# 4th & 5th: Connection refused/reset

# Step 4: Check active connections
# Di IronHills
netstat -an | grep :80 | grep ESTABLISHED | wc -l