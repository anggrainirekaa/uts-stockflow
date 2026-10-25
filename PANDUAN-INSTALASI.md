# Panduan Instalasi & Pemecahan Masalah — StockFlow Blue

## Cara tercepat (Windows)
1. Pasang **PHP 8.4+** (centang ekstensi `pdo_sqlite`, `mbstring`, `openssl`, `fileinfo`, `gd`, `zip`), **Composer**, dan **Node.js 20+**. Pastikan ketiganya ada di `PATH`.
2. Ekstrak zip, lalu klik dua kali **`Jalankan-StockFlow.bat`**.
3. Skrip akan: membuat `.env`, memasang dependensi, membuat `APP_KEY`, migrasi + data demo (hanya pertama kali), membangun tampilan, dan membuka `http://127.0.0.1:8000`.

Akun demo (kata sandi semua `password`): `admin@inventory.test`, `staff@inventory.test`, `kasir@inventory.test`, `pelanggan@inventory.test`.

## Cara manual (semua OS)
```bash
cp .env.example .env
composer install
php artisan key:generate
php artisan migrate                     # database SQLite sudah ada di database/database.sqlite (berisi data demo)
php artisan storage:link
npm install && npm run build
php artisan serve
```
Database bawaan adalah **SQLite** dan **sudah disertakan** di `database/database.sqlite`, lengkap dengan tabel dan data demo, jadi tidak perlu memasang atau menyalakan server database. Untuk mengulang dari data demo awal: `php artisan migrate:fresh --seed`.
Untuk MySQL/MariaDB (XAMPP/Laragon): buat database kosong `stockflow`, ubah `.env` menjadi `DB_CONNECTION=mysql` dan isi `DB_HOST/DB_PORT/DB_DATABASE/DB_USERNAME/DB_PASSWORD`, lalu `php artisan migrate --seed`.

## Menjalankan pemeliharaan otomatis
Aplikasi menjalankan pemeriksaan kedaluwarsa & anomali otomatis paling sering sekali per 6 jam saat dashboard dibuka. Untuk berjalan terjadwal harian, tambahkan scheduler (`php artisan schedule:work` saat pengembangan, atau cron `* * * * * php artisan schedule:run`). Manual: `php artisan stockflow:maintenance`.

## Menjalankan tes
```bash
php artisan test
```

## Pemecahan masalah
| Gejala | Penyebab umum | Solusi |
| --- | --- | --- |
| `Your requirements could not be resolved` | PHP di bawah 8.4 atau ekstensi PHP belum aktif | Pasang PHP 8.4+ dan aktifkan ekstensi di `php.ini` (cek `php -v`, `php -m`). |
| Halaman tampil tanpa gaya / error `Vite manifest not found` | Tampilan belum dibangun | `npm install && npm run build`. |
| `npm install` gagal | Tidak ada internet / registry diblokir | Sambungkan internet lalu ulangi; `npm cache clean --force` bila perlu. |
| `could not find driver` | Ekstensi `pdo_sqlite`/`pdo_mysql` mati | Aktifkan di `php.ini` (hapus `;` di depan `extension=pdo_sqlite`). |
| `No application encryption key has been specified` | `APP_KEY` kosong | `php artisan key:generate`. |
| Gambar produk tidak muncul | Tautan storage belum dibuat | `php artisan storage:link`. |
| Sesi/login terus kembali ke halaman login | Cache lama / `.env` berubah | `php artisan optimize:clear`. |
| Port 8000 terpakai | Aplikasi lain memakai port | `php artisan serve --port=8001`. |
| Ingin mengulang data demo | — | `php artisan migrate:fresh --seed` (**menghapus semua data**). |
| Kamera barcode tidak bisa dibuka | Peramban belum mendukung `BarcodeDetector` atau izin kamera ditolak | Pakai Chrome/Edge terbaru lewat `localhost`/HTTPS, atau scanner USB / ketik manual. |
| Halaman error 500 | Kesalahan di server | Lihat `storage/logs/laravel.log` (halaman error tidak menampilkan stack trace). |

## Catatan: tanpa file kunci paket
Proyek ini sengaja **tidak** menyertakan `composer.lock` dan `package-lock.json` (file itu berisi alamat unduhan paket). Saat `composer install` / `npm install` pertama kali dijalankan, versi paket dipilih otomatis sesuai `composer.json` / `package.json` dan file kunci dibuat di komputer Anda. Setelah berhasil, simpan file kunci tersebut agar instalasi berikutnya memakai versi yang sama.
