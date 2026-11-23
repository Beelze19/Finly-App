#!/usr/bin/env bash
# Setup untuk macOS / Linux
set -e
if [ ! -d android ]; then
  cp lib/main.dart lib/main.dart.bak
  flutter create --project-name finly --org com.finly .
  cp lib/main.dart.bak lib/main.dart && rm lib/main.dart.bak
  rm -f test/widget_test.dart
fi
cp android_patch/AndroidManifest.xml android/app/src/main/AndroidManifest.xml
flutter pub get
echo "Selesai. Salin folder 'backend' ke htdocs sebagai 'finly_api' (XAMPP/MAMP/LAMP), import database/database.sql, lalu jalankan: flutter run"
