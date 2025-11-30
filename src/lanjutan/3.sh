#wilderland

# Network info
KHAMUL_SUBNET="10.76.2.192/29"  # A11 - BLOCK THIS!
DURIN_SUBNET="10.76.2.128/26"   # A10 - KEEP THIS!

# Clear existing rules
iptables -F INPUT
iptables -F OUTPUT
iptables -F FORWARD

# Allow established connections
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A OUTPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A FORWARD -m state --state ESTABLISHED,RELATED -j ACCEPT

# Allow loopback
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT

# ===== ISOLATE KHAMUL =====
iptables -A INPUT -s $KHAMUL_SUBNET -j DROP
iptables -A OUTPUT -d $KHAMUL_SUBNET -j DROP
iptables -A FORWARD -s $KHAMUL_SUBNET -j DROP
iptables -A FORWARD -d $KHAMUL_SUBNET -j DROP

# ===== EXPLICITLY ALLOW DURIN (IMPORTANT!) =====
iptables -I FORWARD 1 -s $DURIN_SUBNET -j ACCEPT
iptables -I FORWARD 1 -d $DURIN_SUBNET -j ACCEPT
iptables -I INPUT 1 -s $DURIN_SUBNET -j ACCEPT
iptables -I OUTPUT 1 -d $DURIN_SUBNET -j ACCEPT

# Allow other traffic
iptables -A INPUT -j ACCEPT
iptables -A OUTPUT -j ACCEPT
iptables -A FORWARD -j ACCEPT

# Step 3: Verify rules
bashiptables -L -v -n --line-numbers | grep "10.76.2.192\|10.76.2.128"

# Step 4: Testing
# Test 1: From Khamul (should FAIL)
# Di Khamul client
ping 8.8.8.8 -c 3
ping 10.76.2.193 -c 3  # Gateway
curl http://10.76.2.230 -m 5
# Expected: ALL BLOCKED!

# Test 2: To Khamul from outside (should FAIL)
# Di Osgiliath
ping 10.76.2.194 -c 3  # Khamul IP
# Expected: Timeout atau unreachable

# Test 3: From Durin (should SUCCESS - NOT BLOCKED!)
# Di Durin client
ping 8.8.8.8 -c 3
curl http://10.76.2.230