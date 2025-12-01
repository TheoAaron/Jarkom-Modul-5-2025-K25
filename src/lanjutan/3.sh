#wilderland

KHAMUL_SUBNET="10.76.2.192/29"  # A11 (5 hosts) - BLOCK THIS!
DURIN_SUBNET="10.76.2.128/26"   # A10 (50 hosts) - MUST WORK!

# ===== STEP 1: FLUSH ALL RULES =====
iptables -F INPUT
iptables -F OUTPUT
iptables -F FORWARD
iptables -X

# ===== STEP 2: SET DEFAULT POLICIES =====
iptables -P INPUT ACCEPT
iptables -P OUTPUT ACCEPT
iptables -P FORWARD ACCEPT

# ===== STEP 3: ALLOW DURIN FIRST (CRITICAL!) =====
# These rules MUST come before Khamul blocking rules!

# Allow Durin in all chains with highest priority
iptables -A FORWARD -s $DURIN_SUBNET -j ACCEPT
iptables -A FORWARD -d $DURIN_SUBNET -j ACCEPT
iptables -A INPUT -s $DURIN_SUBNET -j ACCEPT
iptables -A OUTPUT -d $DURIN_SUBNET -j ACCEPT

# ===== STEP 4: BLOCK KHAMUL =====

# Block Khamul in all chains
iptables -A FORWARD -s $KHAMUL_SUBNET -j DROP
iptables -A FORWARD -d $KHAMUL_SUBNET -j DROP
iptables -A INPUT -s $KHAMUL_SUBNET -j DROP
iptables -A OUTPUT -d $KHAMUL_SUBNET -j DROP

# ===== STEP 5: ALLOW ESTABLISHED CONNECTIONS =====
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A OUTPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A FORWARD -m state --state ESTABLISHED,RELATED -j ACCEPT

# Allow loopback
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT

# ===== VERIFICATION =====

iptables -L FORWARD -v -n --line-numbers | head -10
iptables -L INPUT -v -n --line-numbers | grep -E "10.76.2.192|10.76.2.128" | head -5

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