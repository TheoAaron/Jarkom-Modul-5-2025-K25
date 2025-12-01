# KONFIGURASI JARINGAN MODUL 5

## GRAFIK PEMBAGIAN IP

![Grafik IP](/Assets/Grafik-PembagianIP.png)

## DAFTAR NODE & FUNGSI

| Node | IP Address | Fungsi |
|------|------------|--------|
| Osgiliath | 10.76.2.205, 10.76.2.221, 10.76.2.233 | Router Utama |
| Minastir | 10.76.2.206, 10.76.2.209, 10.76.1.1 | Router + DHCP Relay |
| Pelargir | 10.76.2.210, 10.76.2.213, 10.76.2.217 | Router |
| AnduinBanks | 10.76.2.214, 10.76.2.1 | Router + DHCP Relay |
| Moria | 10.76.2.222, 10.76.2.225, 10.76.2.229 | Router |
| Wilderland | 10.76.2.230, 10.76.2.129, 10.76.2.193 | Router |
| Rivendell | 10.76.2.234, 10.76.2.201 | Router + DHCP Relay |
| Vilya | 10.76.2.202 | DHCP Server |
| Narya | 10.76.2.203 | DNS Server |
| Palantir | 10.76.2.218 | Web Server |
| IronHills | 10.76.2.226 | Web Server |
| Gilgalad | DHCP | Client (100 host) |
| Cirdan | DHCP | Client (20 host) |
| Elendil | DHCP | Client (200 host) |
| Isildur | DHCP | Client (30 host) |
| Durin | DHCP | Client (50 host) |
| Khamul | DHCP | Client (5 host) |

## TESTING

### Test Koneksi
```bash
ping 10.76.2.203 -c 3     # Test ke DNS Server
ping 10.76.2.202 -c 3     # Test ke DHCP Server
```

### Test Web Server
```bash
curl 10.76.2.218          # Palantir
curl 10.76.2.226          # IronHills
```

### Cek IP Client
```bash
ip a                      # Lihat IP yang didapat dari DHCP
```

### Test DNS
```bash
nslookup google.com       # Test DNS resolution
```

### Cek Route
```bash
route -n                  # Lihat routing table
```

## STRUKTUR FILE

Semua konfigurasi sudah digabung dalam satu file per node:
- Konfigurasi network interface
- Routing statis
- Instalasi dan konfigurasi service (DHCP/DNS/Web/Relay)

Tidak ada lagi file terpisah seperti `*_Relay.sh`, `*_DHCP.sh`, dll.

## MISI 2: MENEMUKAN JEJAK KEGELAPAN (SECURITY RULES)

### 2.1 - Routing ke Internet (SNAT Configuration)
**Lokasi:** Osgiliath  
**Tujuan:** Mengkonfigurasi NAT agar jaringan internal dapat akses internet tanpa MASQUERADE

```bash
# Sudah dikonfigurasi di Osgiliath.sh
iptables -t nat -A POSTROUTING -s 10.76.0.0/16 -o eth0 -j SNAT --to-source $ETH0_IP
```

**Testing:**
```bash
# Dari client manapun (Gilgalad, Elendil, dll)
ping 8.8.8.8 -c 3
curl google.com
```

### 2.2 - Proteksi Vilya dari PING
**Lokasi:** Vilya (DHCP Server)  
**File:** `src/lanjutan/2_2.sh`

**Konfigurasi:**
- BLOCK incoming ICMP echo-request (PING ke Vilya)
- ALLOW outgoing ICMP echo-request (PING dari Vilya)

**Testing:**
```bash
# Test 1: Ping FROM Vilya (should SUCCESS)
# Di Vilya
ping 10.76.2.201 -c 3  # Ping gateway Rivendell

# Test 2: Ping TO Vilya ( should FAIL)
# Di Osgiliath atau client lain
ping 10.76.2.202 -c 3  # Ping Vilya
# Expected: Request timeout
```

### 2.3 - Akses DNS Terbatas (Vilya Only)
**Lokasi:** Narya (DNS Server)  
**File:** `src/lanjutan/2_3.sh`

**Konfigurasi:**
- ALLOW DNS queries hanya dari Vilya (10.76.2.202)
- BLOCK DNS queries dari IP lain

**Testing:**
```bash
# Install netcat untuk testing
apt-get update && apt-get install netcat-traditional -y

# Test 1: From Vilya (should SUCCESS)
# Di Vilya
nc -zvu 10.76.2.203 53 -w 3

# Test 2: From Osgiliath (should FAIL)
# Di Osgiliath
nc -zvu 10.76.2.203 53 -w 3
# Expected: Timeout atau connection refused
```

### 2.4 - IronHills Weekend Access Only
**Lokasi:** IronHills (Web Server)  
**File:** `src/lanjutan/2_4.sh`

**Konfigurasi:**
- Akses HTTP hanya di akhir pekan (Sabtu & Minggu)
- Faksi yang diizinkan:
  - Kurcaci & Pengkhianat: Durin (10.76.2.128/26), Khamul (10.76.2.192/29)
  - Manusia: Elendil & Isildur (10.76.1.0/24)

**Testing:**
```bash
# Cek hari saat ini
date +"%A, %Y-%m-%d"

# Test pada WEEKDAY (should FAIL)
# Dari Durin/Khamul/Elendil
curl http://10.76.2.230 -m 5
# Expected: Connection timeout

# Simulasi SATURDAY untuk testing
# Di IronHills
date -s "Sat Nov 30 10:00:00 2024"

# Test ulang (should SUCCESS)
# Dari Durin/Khamul/Elendil
curl http://10.76.2.230
# Expected: "Welcome to IronHills"
```

### 2.5 - Palantir Time-Based Access
**Lokasi:** Palantir (Web Server)  
**File:** `src/lanjutan/2_5.sh`

**Konfigurasi:**
- Faksi Elf (Gilgalad & Cirdan - 10.76.2.0/25): 07:00 - 15:00
- Faksi Manusia (Elendil & Isildur - 10.76.1.0/24): 17:00 - 23:00

**Testing:**
```bash
# Cek waktu saat ini
date +"%H:%M"

# Test Faksi Elf (jam 14:xx - dalam window)
# Dari Gilgalad
curl http://10.76.2.222
# Expected: "Welcome to Palantir"

# Test Faksi Manusia (jam 14:xx - di luar window)
# Dari Elendil
curl http://10.76.2.222 -m 5
# Expected: Connection timeout

# Simulasi jam 19:00 untuk test Manusia
# Di Palantir
date -s "2024-11-27 19:00:00"

# Test Manusia (should SUCCESS)
curl http://10.76.2.222
# Expected: "Welcome to Palantir"
```

### 2.6 - Port Scan Detection & Blocking
**Lokasi:** Palantir (Web Server)  
**File:** `src/lanjutan/2_6.sh`

**Konfigurasi:**
- Blokir scan > 15 port dalam 20 detik
- Blokir SEMUA traffic dari IP yang terdeteksi scan
- Log dengan prefix "PORT_SCAN_DETECTED"

**Testing:**
```bash
# Test 1: Normal access (should work)
# Dari Elendil
curl http://10.76.2.222
# Expected: "Welcome to Palantir"

# Test 2: Port scan (should be blocked)
# Dari Elendil
apt update && apt install nmap -y
nmap -p 1-100 10.76.2.222
# Expected: Scan timeout/hang setelah ~15 ports

# Test 3: After blocked, semua akses ditolak
# Dari Elendil (yang tadi nmap)
ping 10.76.2.222 -c 3
curl http://10.76.2.222
# Expected: SEMUA blocked!

# Check logs di Palantir
dmesg | grep PORT_SCAN_DETECTED
```

### 2.7 - Connection Rate Limiting
**Lokasi:** IronHills (Web Server)  
**File:** `src/lanjutan/2_7.sh`

**Konfigurasi:**
- Maximum 3 koneksi concurrent per IP
- Koneksi ke-4 dan seterusnya akan di-REJECT

**Testing:**
```bash
# Test 1: Open 3 connections (should work)
# Dari Durin/Elendil
for i in {1..3}; do
  (echo "GET / HTTP/1.0" | nc 10.76.2.230 80 && echo "Connection $i: OK") &
done

# Test 2: Open koneksi ke-4 (should FAIL)
sleep 1
echo "GET / HTTP/1.0" | nc 10.76.2.230 80 && echo "Connection 4: OK" || echo "Connection 4: BLOCKED"

# Expected:
# First 3: OK
# 4th: Connection refused/reset
```

### 2.8 - Traffic Redirection (Vilya → Khamul → IronHills)
**Lokasi:** Vilya (DHCP Server)  
**File:** `src/lanjutan/2_8.sh`

**Konfigurasi:**
- Redirect semua traffic dari Vilya tujuan Khamul subnet → IronHills
- Menggunakan DNAT (Destination NAT)

**Testing:**
```bash
# Terminal 1 - Di IronHills (monitor traffic)
tcpdump -i eth0 -n 'host 10.76.2.202 and port 80'

# Terminal 2 - Di Vilya
# Coba akses IP Khamul, akan redirect ke IronHills
curl http://10.76.2.194

# Expected di IronHills tcpdump:
# ... 10.76.2.202.xxxxx > 10.76.2.230.80: ... (SYN)

# Expected curl response:
# "Welcome to IronHills"
```

## MISI 3: ISOLASI SANG NAZGÛL

### 3 - Blokir Total Khamul Subnet
**Lokasi:** Wilderland (Router)  
**File:** `src/lanjutan/3.sh`

**CRITICAL:** Yang diblokir adalah Khamul (10.76.2.192/29 - 5 host), BUKAN Durin (10.76.2.128/26 - 50 host)!

**Konfigurasi:**
- ALLOW Durin subnet dengan prioritas tertinggi (rules pertama)
- BLOCK semua traffic Khamul (INPUT, OUTPUT, FORWARD)
- Khamul tidak bisa akses keluar DAN tidak bisa diakses dari luar

**Testing:**
```bash
# Test 1: From Khamul (should FAIL - totally isolated)
# Di Khamul client
ping 8.8.8.8 -c 3              # Internet
ping 10.76.2.193 -c 3          # Gateway
curl http://10.76.2.230 -m 5   # IronHills
nc -zv 10.76.2.203 53          # DNS
# Expected: ALL BLOCKED!

# Test 2: To Khamul from outside (should FAIL)
# Di Osgiliath
ping 10.76.2.194 -c 3  # Khamul IP
# Expected: Timeout atau unreachable

# Test 3: Durin HARUS tetap berfungsi (should SUCCESS)
# Di Durin client
ping 8.8.8.8 -c 3
curl http://10.76.2.230
ping 10.76.2.129 -c 3  # Gateway
# Expected: SEMUA SUCCESS!

# Verify rules di Wilderland
iptables -L FORWARD -v -n --line-numbers | head -10
iptables -L INPUT -v -n | grep -E "10.76.2.192|10.76.2.128"
```

**Hasil yang diharapkan:**
- Durin (50 host) tetap lancar akses semua
- Khamul (5 host) terisolasi total
- Jika Durin ikut terblokir = SALAH KONFIGURASI!
