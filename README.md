# 🚀 Telegram Bot Auto-Seller VPS (QRIS Ready)

![Python Version](https://img.shields.io/badge/python-3.8%2B-blue)
![Telegram Bot API](https://img.shields.io/badge/pyTelegramBotAPI-latest-green)
![Platform](https://img.shields.io/badge/platform-Ubuntu%20%7C%20Debian-lightgrey)

Sistem Bot Telegram otomatis untuk berjualan akun VPS 24/7. Dilengkapi dengan auto-installer pintar yang akan mengatur *environment*, mengamankan token, dan mengonfigurasi bot agar berjalan non-stop di *background* VPS Anda.

---

## ✨ Fitur Utama

- 🤖 **Interaktif & Mudah Digunakan:** Menggunakan kombinasi *Reply Keyboard* (Menu Utama) dan *Inline Keyboard* (Katalog Produk).
- 💳 **Siap Integrasi QRIS:** Kerangka kode sudah disiapkan untuk menyambung ke API Payment Gateway pilihan Anda.
- ⚡ **Auto-Installer Script:** Cukup jalankan satu skrip, dan semua dependensi terinstal otomatis.
- 🛡️ **Berjalan 24/7 (Systemd):** Bot otomatis menjadi *service daemon* yang tidak akan mati meskipun terminal SSH ditutup, dan akan otomatis menyala saat VPS *restart*.
- 🔒 **Aman (Environment Variables):** Token dan ID Admin disimpan di `.env` yang tidak akan terunggah ke publik.

---

## 🛠️ Instalasi Cepat (Satu Kali Tempel)

Pastikan Anda sudah login ke VPS (Ubuntu/Debian) Anda. **Salin semua perintah di bawah ini, lalu *paste* (tempel) ke terminal VPS Anda, dan tekan Enter:**

```bash
wget -O install.sh https://raw.githubusercontent.com/fikystorez/bot-store/refs/heads/main/install.sh
chmod +x install.sh
./install.sh
