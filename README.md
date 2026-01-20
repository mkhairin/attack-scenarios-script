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
