CREATE DATABASE IF NOT EXISTS finly_db CHARACTER SET utf8mb4;
USE finly_db;

CREATE TABLE IF NOT EXISTS users (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  email VARCHAR(100) NOT NULL UNIQUE,
  password VARCHAR(255) NOT NULL,
  phone VARCHAR(20) NULL,
  expense_limit TINYINT UNSIGNED NOT NULL DEFAULT 70,   -- batas pengeluaran sehat (% dari pemasukan)
  savings_target TINYINT UNSIGNED NOT NULL DEFAULT 20,  -- target tabungan (% dari pemasukan)
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS transactions (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  type ENUM('income','expense') NOT NULL,
  category VARCHAR(50) NOT NULL,
  amount DECIMAL(15,2) NOT NULL,
  note VARCHAR(255) NULL,
  trx_date DATE NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);
