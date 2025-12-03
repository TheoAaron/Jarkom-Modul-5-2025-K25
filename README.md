# KONFIGURASI JARINGAN MODUL 5

| Nama                        | NRP        |
| --------------------------- | ---------- |
| Syifa Nurul Alfiah          | 5027241019 |
| Theodorus Aaron Ugraha      | 5027241056 |

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

## MISI 1: MEMETAKAN MEDAN PERANG

### 1.1 - Identifikasi Perangkat

#### Server Infrastructure
| Perangkat | IP Address | Fungsi | Lokasi File |
|-----------|------------|--------|-------------|
| **Vilya** | 10.76.2.202 | DHCP Server | `src/Vilya.sh` |
| **Narya** | 10.76.2.203 | DNS Server | `src/Narya.sh` |
| **Palantir** | 10.76.2.222 | Web Server | `src/Palantir.sh` |
| **IronHills** | 10.76.2.230 | Web Server | `src/IronHills.sh` |

#### Router & DHCP Relay
| Perangkat | Interfaces | Fungsi | Lokasi File |
|-----------|------------|--------|-------------|
| **Osgiliath** | eth0 (DHCP), eth1-eth3 (static) | Router Utama + NAT | `src/Osgiliath.sh` |
| **Minastir** | eth0-eth2 | Router + DHCP Relay | `src/Minastir.sh` |
| **Pelargir** | eth0-eth2 | Router + DHCP Relay | `src/Pelargir.sh` |
| **AnduinBanks** | eth0-eth1 | Router + DHCP Relay | `src/AnduinBanks.sh` |
| **Moria** | eth0-eth2 | Router + DHCP Relay | `src/Moria.sh` |
| **Wilderland** | eth0-eth2 | Router + DHCP Relay | `src/Wilderland.sh` |
| **Rivendell** | eth0-eth1 | Router + DHCP Relay | `src/Rivendell.sh` |

#### Client (Pasukan) - DHCP Enabled
| Pasukan | Jumlah Host | Subnet | Karakter ZZZ | Lokasi File |
|---------|-------------|--------|--------------|-------------|
| **Elendil** | 200 host | 10.76.1.0/24 | Jane | `src/Elendil.sh` |
| **Gilgalad** | 100 host | 10.76.2.0/25 | Ellen | `src/Gilgalad.sh` |
| **Durin** | 50 host | 10.76.2.128/26 | Caesar | `src/Durin.sh` |
| **Isildur** | 30 host | 10.76.1.0/24 | Policeboo | `src/Isildur.sh` |
| **Cirdan** | 20 host | 10.76.2.0/25 | Lycaon | `src/Cirdan.sh` |
| **Khamul** | 5 host | 10.76.2.192/29 | Burnice (Target) | `src/Khamul.sh` |

### 1.2 - Pohon Subnet (VLSM Tree)
```
Prefix Kelompok: 10.76.0.0/16
│
├─ A6: 10.76.1.0/24 (Elendil & Isildur - 230 host) ◯
│
└─ 10.76.2.0/23
   ├─ A4: 10.76.2.0/25 (Gilgalad & Cirdan - 120 host) ◯
   │
   └─ 10.76.2.128/24
      ├─ A10: 10.76.2.128/26 (Durin - 51 host) ◯
      │
      └─ 10.76.2.192/25
         ├─ A13: 10.76.2.200/29 (Vilya & Narya - 6 host) ◯
         ├─ A1: 10.76.2.208/30 (Osgiliath-Minastir)
         ├─ A2: 10.76.2.212/30 (Minastir-Pelargir)
         ├─ A3: 10.76.2.216/30 (Pelargir-AnduinBanks)
         ├─ A5: 10.76.2.220/30 (Pelargir-Palantir)
         ├─ A7: 10.76.2.224/30 (Osgiliath-Moria)
         ├─ A8: 10.76.2.228/30 (Moria-IronHills)
         ├─ A9: 10.76.2.232/30 (Moria-Wilderland)
         ├─ A12: 10.76.2.236/30 (Osgiliath-Rivendell)
         └─ A11: 10.76.2.192/29 (Khamul - 5 host) ◯

◯ = Subnet yang dilingkari (Client Networks)
```

### 1.3 - Tabel Pembagian IP Lengkap

| Subnet | Network ID | Netmask | Broadcast | Range IP | Gateway | Jumlah Host |
|--------|------------|---------|-----------|----------|---------|-------------|
| **A1** | 10.76.2.208/30 | 255.255.255.252 | 10.76.2.211 | .209-.210 | - | 2 |
| **A2** | 10.76.2.212/30 | 255.255.255.252 | 10.76.2.215 | .213-.214 | - | 2 |
| **A3** | 10.76.2.216/30 | 255.255.255.252 | 10.76.2.219 | .217-.218 | - | 2 |
| **A4** | 10.76.2.0/25 | 255.255.255.128 | 10.76.2.127 | .2-.126 | .1 | 120 |
| **A5** | 10.76.2.220/30 | 255.255.255.252 | 10.76.2.223 | .221-.222 | - | 2 |
| **A6** | 10.76.1.0/24 | 255.255.255.0 | 10.76.1.255 | .2-.254 | .1 | 230 |
| **A7** | 10.76.2.224/30 | 255.255.255.252 | 10.76.2.227 | .225-.226 | - | 2 |
| **A8** | 10.76.2.228/30 | 255.255.255.252 | 10.76.2.231 | .229-.230 | - | 2 |
| **A9** | 10.76.2.232/30 | 255.255.255.252 | 10.76.2.235 | .233-.234 | - | 2 |
| **A10** | 10.76.2.128/26 | 255.255.255.192 | 10.76.2.191 | .130-.190 | .129 | 51 |
| **A11** | 10.76.2.192/29 | 255.255.255.248 | 10.76.2.199 | .194-.198 | .193 | 5 |
| **A12** | 10.76.2.236/30 | 255.255.255.252 | 10.76.2.239 | .237-.238 | - | 2 |
| **A13** | 10.76.2.200/29 | 255.255.255.248 | 10.76.2.207 | .201-.206 | .201 | 6 |

### 1.4 - Topologi Jaringan
```
                        Internet (NAT Cloud)
                                |
                          [Osgiliath] (Router Utama)
                          /    |    \
                         /     |     \
                  [Minastir] [Moria] [Rivendell]
                   /    |      |   \      |
                  /     |      |    \     |
           [Pelargir] [SW2] [SW8] [Wilderland] [SW9]
            /    |      |      |      |    |     |
           /     |      |      |      |    |     |
    [AnduinBanks] [Palantir] [IronHills] [SW6] [SW7] [Vilya & Narya]
         |                                |    |
       [SW5]                           [SW10][SW11]
         |                               |    |
    [Gilgalad & Cirdan]              [Durin][Khamul]
    
         [SW2] = Elendil & Isildur
```

### 1.5 - Konfigurasi Routing

Semua konfigurasi routing sudah terintegrasi dalam file shell script masing-masing node.

#### Cara Setup Jaringan:

**Step 1: Setup Router Utama (Osgiliath)**
```bash
bash src/Osgiliath.sh
```
- Enable IP forwarding
- Setup NAT dengan SNAT (bukan MASQUERADE)
- Routing ke semua cabang (Minastir, Moria, Rivendell)

**Step 2: Setup Router Cabang**
```bash
# Cabang Minastir
bash src/Minastir.sh
bash src/Pelargir.sh
bash src/AnduinBanks.sh

# Cabang Moria
bash src/Moria.sh
bash src/Wilderland.sh

# Cabang Rivendell
bash src/Rivendell.sh
```

**Step 3: Setup Server Infrastructure**
```bash
# DHCP Server
bash src/Vilya.sh

# DNS Server
bash src/Narya.sh

# Web Servers
bash src/Palantir.sh
bash src/IronHills.sh
```

**Step 4: Setup Client (Pasukan)**
```bash
bash src/Gilgalad.sh
bash src/Cirdan.sh
bash src/Elendil.sh
bash src/Isildur.sh
bash src/Durin.sh
bash src/Khamul.sh
```

### 1.6 - Konfigurasi Service

#### A. DHCP Server (Vilya)

**File:** `src/Vilya.sh`

**Subnet Configuration:**
```bash
# A4: Gilgalad & Cirdan (120 host)
subnet 10.76.2.0 netmask 255.255.255.128 {
    range 10.76.2.2 10.76.2.126;
    option routers 10.76.2.1;
    option domain-name-servers 10.76.2.203;
}

# A6: Elendil & Isildur (230 host)
subnet 10.76.1.0 netmask 255.255.255.0 {
    range 10.76.1.2 10.76.1.254;
    option routers 10.76.1.1;
    option domain-name-servers 10.76.2.203;
}

# A10: Durin (51 host)
subnet 10.76.2.128 netmask 255.255.255.192 {
    range 10.76.2.130 10.76.2.190;
    option routers 10.76.2.129;
    option domain-name-servers 10.76.2.203;
}

# A11: Khamul (5 host)
subnet 10.76.2.192 netmask 255.255.255.248 {
    range 10.76.2.194 10.76.2.198;
    option routers 10.76.2.193;
    option domain-name-servers 10.76.2.203;
}
```

**Verifikasi:**
```bash
# Di Vilya
service isc-dhcp-server status
cat /var/log/syslog | grep dhcpd
```

#### B. DHCP Relay

**Router yang berfungsi sebagai DHCP Relay:**
- AnduinBanks
- Minastir
- Pelargir
- Rivendell
- Moria
- Wilderland

**Configuration Pattern:**
```bash
# Di setiap DHCP Relay
cat > /etc/default/isc-dhcp-relay << 'EOF'
SERVERS="10.76.2.202"    # IP Vilya (DHCP Server)
INTERFACES="eth0 eth1 eth2"  # Sesuaikan dengan interface
OPTIONS=""
EOF

service isc-dhcp-relay restart
```

**Verifikasi:**
```bash
# Di router relay
service isc-dhcp-relay status
```

#### C. DNS Server (Narya)

**File:** `src/Narya.sh`

**Configuration:**
```bash
# /etc/bind/named.conf.options
options {
    directory "/var/cache/bind";
    forwarders {
        192.168.122.1;  # Forward ke DNS external
    };
    allow-query { any; };
    auth-nxdomain no;
    listen-on-v6 { any; };
};
```

**Verifikasi:**
```bash
# Di Narya
service bind9 status
named-checkconf

# Test dari client
nslookup google.com 10.76.2.203
```

#### D. Web Server (Apache)

**Palantir (10.76.2.222):**
```bash
# File: src/Palantir.sh
cat > /var/www/html/index.html << 'EOF'
Welcome to Palantir
EOF

service apache2 start
```

**IronHills (10.76.2.230):**
```bash
# File: src/IronHills.sh
cat > /var/www/html/index.html << 'EOF'
Welcome to IronHills
EOF

service apache2 start
```

**Verifikasi:**
```bash
# Test dari client
curl http://10.76.2.222  # Palantir
curl http://10.76.2.230  # IronHills
```

### 1.7 - Testing Konektivitas

#### Test 1: Verifikasi IP Client (DHCP)
```bash
# Di setiap client (Gilgalad, Elendil, dll)
ip a | grep inet

# Expected output contoh (Gilgalad):
# inet 10.76.2.5/25 brd 10.76.2.127 scope global eth0
```

#### Test 2: Test Gateway
```bash
# Di Gilgalad (gateway: 10.76.2.1)
ping 10.76.2.1 -c 3

# Di Elendil (gateway: 10.76.1.1)
ping 10.76.1.1 -c 3

# Di Durin (gateway: 10.76.2.129)
ping 10.76.2.129 -c 3
```

#### Test 3: Test DNS Resolution
```bash
# Di semua client
nslookup google.com
# Expected: Resolved ke IP address

ping google.com -c 3
# Expected: Reply dari google.com
```

#### Test 4: Test Inter-Client Communication
```bash
# Dari Gilgalad ke Elendil
ping <IP_Elendil> -c 3

# Dari Durin ke Cirdan
ping <IP_Cirdan> -c 3
```

#### Test 5: Test Web Server Access
```bash
# Dari semua client
curl http://10.76.2.222          # Palantir
# Expected: "Welcome to Palantir"

curl http://10.76.2.230          # IronHills
# Expected: "Welcome to IronHills"
```

#### Test 6: Test Internet Access
```bash
# Dari semua client
ping 8.8.8.8 -c 3
# Expected: Reply from 8.8.8.8

curl google.com
# Expected: HTML response
```

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


## Revisi
<img width="1366" height="768" alt="image" src="https://github.com/user-attachments/assets/5d4cbc20-cc39-471a-9d11-0ad0e4f5f243" />

Oke bestie, ini **paragraf penjelasan + code block** jadi satu bagian README yang rapi:

---

### **Penjelasan Perubahan**

Dengan menambahkan perintah untuk meng-install dan menyalakan `rsyslog`,  akhirnya mengaktifkan sistem logging kernel yang sebelumnya belum berjalan. Walaupun iptables sudah melakukan logging dengan `LOG --log-prefix`, log tersebut tidak pernah muncul karena tidak ada daemon yang menangkap dan menuliskannya ke file log. Setelah `rsyslog` aktif, semua pesan kernel—including log dari chain `PORT_SCAN`—langsung mulai muncul di `dmesg`, `journalctl`, dan `/var/log/kern.log`. Perintah `dmesg -c`  digunakan untuk mengosongkan buffer sebelum test, dan saat melakukan scanning menggunakan `nmap`, rule `recent` melewati hitcount 15 sehingga memicu logging dan akhirnya bisa tampil ketika dicek melalui `dmesg | grep PORT_SCAN`.

```bash
apt update
apt install rsyslog -y
service rsyslog start

dmesg -c
nmap -p 1-100 10.76.2.222

dmesg | grep PORT_SCAN
```

---





