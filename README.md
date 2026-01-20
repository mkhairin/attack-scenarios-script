# Automasi Pengujian & Validasi Suricata IDS (Interleaved Method)

Repository ini berisi kumpulan *automation scripts* (Bash & Python) yang dikembangkan untuk keperluan Tugas Akhir/Skripsi mengenai analisis performa **Suricata IDS**.

Proyek ini menggunakan metodologi **Interleaved Design**, di mana serangan siber (Attacks) dijalankan secara bergantian dengan lalu lintas normal (Normal Traffic) dalam sistem ronde (Rounds) untuk menguji tingkat akurasi (Detection Rate) dan kesalahan deteksi (False Positive) pada IDS.

## 📋 Fitur Utama

* **Interleaved Execution:** Menjalankan serangan dan trafik normal secara otomatis dalam satu siklus ronde.
* **7 Attack Vectors:** Mencakup Network Reconnaissance, Brute Force, DoS, hingga Web Application Attacks.
* **Noise Generator:** Mensimulasikan aktivitas user legal (ping, browsing, download) untuk menguji False Positive.
* **Verbose Reporting:** Menampilkan *Payload* dan *Command* yang dieksekusi secara real-time di terminal untuk kebutuhan dokumentasi laporan.
* **Log Analysis:** Disertai script Python untuk merekapitulasi file `eve.json` Suricata secara otomatis.

## 📂 Struktur Direktori

Pastikan susunan folder di mesin *Attacker* (Kali Linux) Anda seperti berikut:

```text
/skripsi-ids/
├── daily_round.sh        # [MAIN] Script utama pengendali ronde
├── normal_traffic.sh     # [NOISE] Script simulasi trafik normal
├── analyze_logs.py       # [TOOL] Parser log otomatis (Python)
├── README.md             # Dokumentasi ini
├── logs/                 # Folder output (otomatis terisi)
└── attacks/              # Folder modul serangan
    ├── 01_nmap.sh        # Port Scanning
    ├── 02_hydra.sh       # SSH Brute Force
    ├── 03_dos.sh         # DoS (Hping3)
    ├── 04_sqlmap.sh      # SQL Injection
    ├── 05_xss.sh         # XSS (Reflected & Stored)
    ├── 06_trav.sh        # Path Traversal
    └── 07_rce.sh         # RCE (Metasploit)
```

## 🛠️ Prasyarat (Requirements)
- OS Attacker: Kali Linux (Recommended)
- Target Machine: Metasploitable 2 (atau target lain yang diizinkan)
- Tools Terinstall:
 - `nmap`, `hydra`, `hping3`, `sqlmap`, `curl`, `wget`
 - `metasploit-framework` (mfsconsole)
 - `sshpass` (untuk simulasi login SSH normal)
 - `pthon3` (untuk analisis log)

## 🚀 Cara Penggunaan
1. Clone & Persiapan Izin
Clone repository ini ke Kali Linux Anda dan berikan izin eksekusi:
```
git clone [https://github.com/username-anda/repository-ini.git](https://github.com/username-anda/repository-ini.git)
cd repository-ini
chmod +x daily_round.sh normal_traffic.sh attacks/*.sh
mkdir logs
```

2. Konfigurasi Variabel (WAJIB!)
Sebelum menjalankan, Anda HARUS mengedit file script untuk menyesuaikan IP dan Session:
 1. Edit `normal_traffic.sh` & semua file di folder `attacks/`:
    - Ubah `TARGET_IP="192.168.x.x"` sesuai IP Metasploitable Anda.
 2. Edit `attacks/07_rce.sh`:
    - Ubah `LHOST="192.168.x.x"` sesuai IP Kali Linux Anda (untuk Reverse Shell).
 3. Edit `attacks/04_sqlmap.sh`, `05_xss.sh`, `06_trav.sh`:
    - Update variabel `COOKIE="PHPSESSID=..."` dengan session ID login DVWA yang baru.
   
3. Menjalankan Pengujian (Daily Round)
Jalankan script utama. Script ini akan memanggil modul serangan dan trafik normal secara bergantian.
```
./daily_round.sh
```
- Output: Lihat terminal untuk monitoring Payload yang dikirim.
- Hasil: Tersimpan di folder logs/.

4. Analisis Hasil (Parser Log)
Setelah pengujian selesai, salin file `eve.json` dari server Suricata ke folder ini, lalu jalankan:
```
# Salin log (contoh)
cp /var/log/suricata/eve.json .

# Jalankan analisis
python3 analyze_logs.py
```
Script ini akan menghasilkan tabel rekapitulasi jumlah deteksi per kategori serangan.

## 📊 Skenario Pengujian

| Modul | Jenis Serangan | Teknik / Tools | Tujuan Pengujian |
|--------|--------|--------|--------|
| 01 | Reconnaissance | Nmap (SYN, Frag, Decoy) | Deteksi scan port & evasion |
| 02 | Brute Force | Hydra (SSH) | Deteksi login failure threshold | 
| 03 | DoS | Hping3 (ICMP, SYN Flood) | Deteksi anomali trafik/volumetrik |
| 04 | Web Attack | SQLMap (Boolean, Time-based) | Deteksi SQL Injection signature |
| 05 | Web Attack | Curl (XSS Payload) | Deteksi skrip berbahaya di URL/Body |
| 06 | Web Attack | Curl (Directory Traversal) | Deteksi akses file sensitif (/etc/passwd) |
| 07 | Exploitation | Metasploit (Vsftpd, Samba) | Deteksi shellcode & backdoor |
| Noise | Normal Traffic| Wget, Apt, SSH Valid | Menguji False Positive |

## ⚠️ Disclaimer
HANYA UNTUK TUJUAN PENDIDIKAN DAN PENELITIAN. Script ini dibuat khusus untuk pengujian di lingkungan laboratorium terkontrol (Sandboxed Environment). Penggunaan script ini untuk menyerang target tanpa izin adalah tindakan ilegal. Penulis tidak bertanggung jawab atas penyalahgunaan alat ini.
```
---

### Tips Tambahan untuk GitHub Anda:

1.  **Screenshots:** Nanti setelah Anda menjalankan script dan muncul tampilan terminal yang warna-warni (Verbose Mode tadi), ambil *screenshot*-nya. Letakkan di folder `img/` dan tampilkan di README agar terlihat menarik.
2.  **Badge:** Anda bisa menambahkan badge "Bash" atau "Python" di atas judul agar terlihat keren.

Apakah ada bagian dari README ini yang ingin Anda ubah atau tambahkan?
```
