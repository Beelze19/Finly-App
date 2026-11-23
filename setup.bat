@echo off
setlocal
echo ==========================================
echo   FINLY - Setup otomatis (Windows)
echo ==========================================

echo.
echo [1/4] Membuat folder platform Flutter (android, ios, dll)...
if not exist android (
  copy /Y lib\main.dart lib\main.dart.bak >nul
  call flutter create --project-name finly --org com.finly .
  copy /Y lib\main.dart.bak lib\main.dart >nul
  del lib\main.dart.bak
  if exist test\widget_test.dart del test\widget_test.dart
) else (
  echo Folder android sudah ada, dilewati.
)

echo.
echo [2/4] Menerapkan AndroidManifest (izin internet + cleartext HTTP)...
if exist android\app\src\main\AndroidManifest.xml (
  copy /Y android_patch\AndroidManifest.xml android\app\src\main\AndroidManifest.xml >nul
)

echo.
echo [3/4] Mengunduh package (flutter pub get)...
call flutter pub get

echo.
echo [4/4] Menyalin backend PHP ke XAMPP...
if exist C:\xampp\htdocs (
  xcopy /E /I /Y backend C:\xampp\htdocs\finly_api >nul
  echo Backend disalin ke C:\xampp\htdocs\finly_api
) else (
  echo XAMPP tidak ditemukan di C:\xampp. Salin folder "backend" secara manual
  echo ke folder htdocs dan beri nama finly_api.
)

echo.
echo ==========================================
echo Selesai. Langkah berikutnya:
echo  1. Start Apache dan MySQL di XAMPP
echo  2. Import database\database.sql lewat phpMyAdmin
echo  3. Jalankan: flutter run   (atau F5 di VS Code)
echo ==========================================
pause
