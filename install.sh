#!/bin/bash

# ====================================================================
# AUTO INSTALLER & CONFIGURATOR FOR TELEGRAM VPS BOT
# ====================================================================

# Konfigurasi Warna Terminal
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

clear
echo -e "${CYAN}====================================================${NC}"
echo -e "${CYAN}     AUTO INSTALLER BOT TELEGRAM JUALAN VPS         ${NC}"
echo -e "${CYAN}====================================================${NC}"
echo ""

# Memastikan skrip dijalankan di root/sudo untuk setup Systemd nanti
if [ "$EUID" -ne 0 ]; then
  echo -e "${RED}Peringatan: Silakan jalankan skrip ini dengan sudo!${NC}"
  echo -e "Contoh: sudo ./install.sh"
  exit 1
fi

# Mendapatkan user asli (bukan root) untuk path direktori
REAL_USER=${SUDO_USER:-$USER}
CURRENT_DIR=$(pwd)

# --------------------------------------------------------------------
# STEP 1: INPUT KREDENSIAL (MENU SETTING)
# --------------------------------------------------------------------
echo -e "${YELLOW}[1/5] Pengaturan Konfigurasi Bot Interaktif${NC}"
read -p "Masukkan Token Bot Telegram Anda : " BOT_TOKEN
read -p "Masukkan ID Telegram Admin Anda  : " ADMIN_ID
echo ""

# --------------------------------------------------------------------
# STEP 2: MEMBUAT CONFIG FILE (.env & .gitignore)
# --------------------------------------------------------------------
echo -e "${YELLOW}[2/5] Membuat File Konfigurasi Lingkungan (.env)...${NC}"
cat <<EOF > .env
BOT_TOKEN=$BOT_TOKEN
ADMIN_ID=$ADMIN_ID
EOF

# Membuat .gitignore agar token aman tidak ikut ke-up ke GitHub
cat <<EOF > .gitignore
venv/
.env
__pycache__/
*.pyc
EOF
echo -e "${GREEN}✓ File .env dan .gitignore berhasil dibuat.${NC}\n"

# --------------------------------------------------------------------
# STEP 3: INSTALL DEPENDENCIES SYSTEM
# --------------------------------------------------------------------
echo -e "${YELLOW}[3/5] Mengupdate OS dan Menginstal Python3-Venv...${NC}"
apt-get update -y
apt-get install python3 python3-pip python3-venv -y

echo -e "\n${YELLOW}Membuat Virtual Environment & Install Library...${NC}"
python3 -m venv venv
./venv/bin/pip install pyTelegramBotAPI python-dotenv
echo -e "${GREEN}✓ Semua dependensi berhasil diinstal.${NC}\n"

# --------------------------------------------------------------------
# STEP 4: GENERATE SOURCE CODE BOT (bot.py) secara otomatis
# --------------------------------------------------------------------
echo -e "${YELLOW}[4/5] Membuat File Source Code utama (bot.py)...${NC}"
cat << 'EOF' > bot.py
import os
import telebot
from telebot.types import ReplyKeyboardMarkup, KeyboardButton, InlineKeyboardMarkup, InlineKeyboardButton
from dotenv import load_dotenv

# Load token dari .env
load_dotenv()
TOKEN = os.getenv('BOT_TOKEN')
ADMIN_ID = os.getenv('ADMIN_ID')

if not TOKEN:
    print("Error: BOT_TOKEN tidak ditemukan di .env!")
    exit(1)

bot = telebot.TeleBot(TOKEN)

# Menu Utama (Reply Keyboard di bawah)
def menu_utama():
    markup = ReplyKeyboardMarkup(resize_keyboard=True, row_width=2)
    markup.add(
        KeyboardButton("🛒 Beli VPS"),
        KeyboardButton("🧾 Cek Transaksi"),
        KeyboardButton("📞 Hubungi Admin"),
        KeyboardButton("ℹ️ Info Layanan")
    )
    return markup

# Handler /start
@bot.message_handler(commands=['start'])
def send_welcome(message):
    teks = (
        "👋 Selamat datang di *Toko VPS Otomatis*!\n\n"
        "Di sini Anda bisa membeli akun VPS dengan pembayaran QRIS otomatis.\n"
        "Silakan pilih menu di bawah untuk memulai."
    )
    bot.send_message(message.chat.id, teks, parse_mode='Markdown', reply_markup=menu_utama())

# Handler Menu Utama (Text)
@bot.message_handler(func=lambda message: True)
def respon_menu(message):
    chat_id = message.chat.id
    
    if message.text == "🛒 Beli VPS":
        markup = InlineKeyboardMarkup(row_width=1)
        # Callback data akan diproses saat tombol diklik
        markup.add(
            InlineKeyboardButton("🚀 VPS Paket Hemat (1GB RAM) - Rp 50.000", callback_data="buy_vps_1gb"),
            InlineKeyboardButton("⚡ VPS Paket Premium (2GB RAM) - Rp 100.000", callback_data="buy_vps_2gb")
        )
        bot.send_message(chat_id, "📊 *PILIH PAKET VPS ANDA* 📊\n\nSilakan klik salah satu paket di bawah ini:", parse_mode='Markdown', reply_markup=markup)
        
    elif message.text == "🧾 Cek Transaksi":
        bot.send_message(chat_id, "🔍 Kirimkan *ID Transaksi* Anda untuk mengecek status pembayaran terbaru.")
        
    elif message.text == "📞 Hubungi Admin":
        bot.send_message(chat_id, f"🎯 Jika ada kendala, silakan hubungi Admin utama kami.\nID Admin Anda: {ADMIN_ID}\nAtau klik: @AdminGanteng (Ganti dengan username Anda)")
        
    elif message.text == "ℹ️ Info Layanan":
        teks_info = (
            "ℹ️ *INFORMASI LAYANAN TOKO VPS*\n\n"
            "1. Sistem pembayaran menggunakan QRIS otomatis 24 jam.\n"
            "2. Setelah pembayaran sukses, detail VPS (IP, User, Pass) langsung dikirim oleh bot.\n"
            "3. Dilarang menggunakan VPS untuk Torrent, Mining, atau aktivitas Ilegal."
        )
        bot.send_message(chat_id, teks_info, parse_mode='Markdown')

# Handler Aksi Tombol Klik (Inline Keyboard)
@bot.callback_query_handler(func=lambda call: True)
def callback_query(call):
    if call.data == "buy_vps_1gb":
        # Skenario integrasi API Gateway QRIS Anda di sini nanti
        pesan = (
            "⏳ *MENG-GENERATE TAGIHAN QRIS...*\n\n"
            "Produk: VPS Paket Hemat (1GB RAM)\n"
            "Total Tagihan: Rp 50.000\n\n"
            "_[Tempatkan Link/Gambar QRIS API Gateway Anda di sini]_"
        )
        bot.send_message(call.message.chat.id, pesan, parse_mode='Markdown')
        
    elif call.data == "buy_vps_2gb":
        bot.send_message(call.message.chat.id, "⏳ Meng-generate QRIS untuk VPS Paket Premium (Rp 100.000)...")

# Menjalankan bot
if __name__ == '__main__':
    print("Bot Jualan VPS Berhasil Dijalankan!")
    bot.polling(none_stop=True)
EOF

# Menyesuaikan kepemilikan file agar bukan milik root sepenuhnya
chown -R $REAL_USER:$REAL_USER $CURRENT_DIR
echo -e "${GREEN}✓ File bot.py berhasil dibuat.${NC}\n"

# --------------------------------------------------------------------
# STEP 5: REGISTRASI KE SYSTEMD SERVICE (AGAR JALAN 24 JAM)
# --------------------------------------------------------------------
echo -e "${YELLOW}[5/5] Mengonfigurasi Systemd Service agar Bot berjalan 24/7...${NC}"

cat <<EOF > /etc/systemd/system/vps-bot.service
[Unit]
Description=Telegram VPS Seller Bot Service
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=$CURRENT_DIR
ExecStart=$CURRENT_DIR/venv/bin/python3 $CURRENT_DIR/bot.py
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

# Reload daemon dan jalankan service
systemctl daemon-reload
systemctl enable vps-bot.service
systemctl start vps-bot.service

echo ""
echo -e "${CYAN}====================================================${NC}"
echo -e "${GREEN}          PROSES INSTALASI SELESAI!                 ${NC}"
echo -e "${CYAN}====================================================${NC}"
echo -e "• File Konfigurasi : ${GREEN}.env (Aman dari GitHub)${NC}"
echo -e "• Status Bot       : ${GREEN}AKTIF & BERJALAN di Background (Systemd)${NC}"
echo ""
echo -e "Untuk mengecek log / status bot berjalan, gunakan perintah:"
echo -e "${YELLOW}sudo systemctl status vps-bot.service${NC}"
echo -e "Untuk merestart bot jika Anda mengubah kode di kemudian hari:"
echo -e "${YELLOW}sudo systemctl restart vps-bot.service${NC}"
echo -e "${CYAN}====================================================${NC}"
