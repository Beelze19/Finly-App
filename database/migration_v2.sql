-- Jalankan HANYA jika Anda sudah punya database dari versi sebelumnya (v1).
-- Jika memakai database.sql yang baru, file ini tidak perlu dijalankan.
-- (XAMPP memakai MariaDB sehingga "IF NOT EXISTS" didukung.)
USE finly_db;
ALTER TABLE users
  ADD COLUMN IF NOT EXISTS expense_limit TINYINT UNSIGNED NOT NULL DEFAULT 70,
  ADD COLUMN IF NOT EXISTS savings_target TINYINT UNSIGNED NOT NULL DEFAULT 20;
