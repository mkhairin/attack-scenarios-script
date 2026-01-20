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
