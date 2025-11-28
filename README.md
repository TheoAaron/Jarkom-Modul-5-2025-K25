# KONFIGURASI JARINGAN MODUL 5

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
