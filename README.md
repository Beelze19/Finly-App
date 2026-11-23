# Finly – Financial Friendly (Flutter + PHP + MySQL) — v1.1

```
Flutter  →  HTTP (JSON)  →  PHP API (XAMPP)  →  MySQL (phpMyAdmin)
```

## Fitur
| Fitur | Keterangan |
|---|---|
| Daftar & Masuk | Akun tersimpan di MySQL, password ter-hash |
| Beranda | Saldo, pemasukan/pengeluaran bulan ini, ringkasan per kategori |
| **Peringatan keuangan** | Kartu + dialog peringatan jika pengeluaran melewati batas sehat (bawaan 70% dari pemasukan); status Waspada mulai 85% dari batas |
| **Rekomendasi tabungan** | Berapa yang sebaiknya disimpan dari saldo (target bawaan 20% dari pemasukan) dan sisa untuk kebutuhan |
| Pemasukan / Pengeluaran | Form tambah transaksi (nominal, kategori, tanggal, catatan) |
| **Tab Transaksi** | Daftar transaksi per bulan, filter, total, edit, hapus |
| **Tab Laporan** | Grafik 12 bulan, rekap per bulan + status sehat/waspada/tidak sehat, rincian kategori per bulan |
| **Profil** | Edit profil (nama, telepon), Pengaturan (batas pengeluaran & target tabungan), Keamanan (ganti password), Bantuan (FAQ) |

## Struktur
```
lib/
  main.dart                  Login, Register, Beranda, Profil
  core.dart                  Warna, ApiService, helper, logika kesehatan keuangan
  add_transaction_sheet.dart Form tambah/edit transaksi
  transactions_page.dart     Tab Transaksi
  reports_page.dart          Tab Laporan
  profile_pages.dart         Edit Profil, Pengaturan, Keamanan, Bantuan
backend/                     API PHP (12 file)
database/
  database.sql               Database baru (install pertama)
  migration_v2.sql           Untuk yang sudah punya database v1
  sample_data.sql            Data contoh (opsional)
```

## Langkah menjalankan

### 1. Setup otomatis
Ekstrak ZIP → buka di VS Code → Terminal:
```
setup.bat          (Windows)
./setup.sh         (macOS/Linux)
```
Script membuat folder `android/` dkk, memasang izin internet, `flutter pub get`, dan menyalin `backend/` ke `C:\xampp\htdocs\finly_api`. `lib/` tidak ditimpa.

### 2. Database
Start **Apache** + **MySQL** di XAMPP, lalu buka `http://localhost/phpmyadmin`:
- **Instalasi baru:** tab **Import** → `database/database.sql`.
- **Sudah punya database v1:** tab **SQL** → jalankan isi `database/migration_v2.sql` (menambah 2 kolom pengaturan). Data lama aman.

### 3. Salin ulang backend (jika sebelumnya sudah pernah)
Timpa isi `C:\xampp\htdocs\finly_api` dengan folder `backend/` terbaru (ada 8 file PHP baru dan `login.php`, `summary.php`, `config.php` berubah). `setup.bat` melakukannya otomatis.

### 4. Alamat server
Ubah `baseUrl` di `lib/core.dart` (kelas `ApiService`):
| Perangkat | baseUrl |
|---|---|
| Emulator Android | `http://10.0.2.2/finly_api` (default) |
| HP asli | `http://IP_LAPTOP/finly_api` (cek `ipconfig`, satu Wi-Fi, izinkan Apache di firewall) |
| Chrome / Windows desktop | `http://localhost/finly_api` |

### 5. Jalankan
Pilih perangkat di VS Code, tekan **F5** atau `flutter run`.

## Aturan perhitungan
- **Pengeluaran sehat:** pengeluaran ÷ pemasukan bulan berjalan. `≤ 85% × batas` = Sehat, `85% × batas … batas` = Waspada, `> batas` = Tidak sehat. Jika ada pengeluaran tetapi belum ada pemasukan = Tidak sehat.
- **Rekomendasi tabungan:** target = pemasukan × target tabungan%. Disarankan simpan = min(saldo, target). Sisa untuk kebutuhan = saldo − simpan.
- Batas pengeluaran (40–100%) + target tabungan (5–50%) tidak boleh lebih dari 100%. Atur di Profil → Pengaturan Aplikasi.

## Catatan
- Tombol **Kategori** di beranda masih placeholder.
- Untuk produksi: HTTPS, user MySQL khusus (bukan `root` tanpa password), dan token (mis. JWT) agar API tidak bisa diakses hanya dengan menebak `user_id`.

## Troubleshooting
- **"Tidak dapat terhubung ke server"** → Apache aktif? `baseUrl` sesuai perangkat? Folder `finly_api` ada di `htdocs`?
- **Login gagal / error setelah update** → pastikan `migration_v2.sql` sudah dijalankan dan backend sudah ditimpa.
- **Error `withValues`** → `flutter upgrade`.
