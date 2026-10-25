@echo off
setlocal EnableExtensions
title StockFlow - Jalankan Aplikasi
cd /d "%~dp0"

echo ==================================================
echo   StockFlow - menyiapkan dan menjalankan aplikasi
echo ==================================================
echo.

where php >nul 2>nul
if errorlevel 1 ( echo [GAGAL] PHP tidak ditemukan. Pasang PHP 8.4 atau lebih baru dan tambahkan ke PATH. & goto :akhir )
where composer >nul 2>nul
if errorlevel 1 ( echo [GAGAL] Composer tidak ditemukan. Pasang dari https://getcomposer.org & goto :akhir )
where npm >nul 2>nul
if errorlevel 1 ( echo [GAGAL] Node.js/npm tidak ditemukan. Pasang Node.js 20 atau lebih baru. & goto :akhir )

if not exist ".env" (
    echo [1/6] Membuat berkas .env dari .env.example ...
    copy /y ".env.example" ".env" >nul
    set BARU=1
)

if not exist "vendor\autoload.php" (
    echo [2/6] Memasang dependensi PHP - bisa beberapa menit ...
    call composer install --no-interaction
    if errorlevel 1 ( echo [GAGAL] composer install gagal. Lihat PANDUAN-INSTALASI.md bagian Pemecahan Masalah. & goto :akhir )
) else ( echo [2/6] Dependensi PHP sudah ada. )

findstr /b /c:"APP_KEY=base64" ".env" >nul 2>nul
if errorlevel 1 (
    echo [3/6] Membuat APP_KEY ...
    call php artisan key:generate --force
)

if "%DB_CHECK%"=="" (
    findstr /b /c:"DB_CONNECTION=sqlite" ".env" >nul 2>nul
    if not errorlevel 1 if not exist "database\database.sqlite" ( type nul > "database\database.sqlite" & set BARU=1 )
)

echo [4/6] Menjalankan migrasi database ...
call php artisan migrate --force
if errorlevel 1 ( echo [GAGAL] Migrasi gagal. Periksa pengaturan DB_* di .env (jika memakai MySQL, pastikan server menyala dan database ada). & goto :akhir )

if "%BARU%"=="1" (
    echo       Mengisi data demo - hanya saat instalasi pertama ...
    call php artisan db:seed --force
)

call php artisan storage:link >nul 2>nul

if not exist "public\build\manifest.json" (
    echo [5/6] Memasang dan membangun tampilan - butuh internet pada pemasangan pertama ...
    call npm install
    if errorlevel 1 ( echo [GAGAL] npm install gagal. Periksa koneksi internet. & goto :akhir )
    call npm run build
    if errorlevel 1 ( echo [GAGAL] npm run build gagal. & goto :akhir )
) else ( echo [5/6] Tampilan sudah dibangun. )

echo [6/6] Menjalankan server di http://127.0.0.1:8000
echo.
echo   Akun demo - kata sandi semua: password
echo     Admin     : admin@inventory.test
echo     Staff     : staff@inventory.test
echo     Pelanggan : pelanggan@inventory.test
echo.
echo   Tekan Ctrl+C untuk menghentikan server.
echo.
start "" "http://127.0.0.1:8000"
call php artisan serve --host=127.0.0.1 --port=8000

:akhir
echo.
pause
endlocal
